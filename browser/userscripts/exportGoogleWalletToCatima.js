//? export from https://wallet.google.com/wallet/passes to https://catima.app/
(async function exportGoogleWalletToCatima() {
  function crc32(buf) {
    let table = new Int32Array(256);
    for (let i = 0; i < 256; i++) {
      let c = i;
      for (let k = 0; k < 8; k++) c = c & 1 ? 0xedb88320 ^ (c >>> 1) : c >>> 1;
      table[i] = c;
    }
    let crc = -1;
    for (let i = 0; i < buf.length; i++) crc = (crc >>> 8) ^ table[(crc ^ buf[i]) & 0xff];
    return (crc ^ -1) >>> 0;
  }

  function makeZip(files) {
    const localHeaders = [];
    const cdHeaders = [];
    let offset = 0;

    for (const file of files) {
      const nameBuf = new TextEncoder().encode(file.name);
      const dataBuf = file.data;
      const crc = crc32(dataBuf);
      const size = dataBuf.length;

      const lh = new Uint8Array(30 + nameBuf.length);
      const dvLh = new DataView(lh.buffer);
      dvLh.setUint32(0, 0x04034b50, true);
      dvLh.setUint16(4, 20, true);
      dvLh.setUint16(6, 0, true);
      dvLh.setUint16(8, 0, true);
      dvLh.setUint16(10, 0, true);
      dvLh.setUint16(12, 0, true);
      dvLh.setUint32(14, crc, true);
      dvLh.setUint32(18, size, true);
      dvLh.setUint32(22, size, true);
      dvLh.setUint16(26, nameBuf.length, true);
      dvLh.setUint16(28, 0, true);
      lh.set(nameBuf, 30);
      localHeaders.push(lh, dataBuf);

      const cd = new Uint8Array(46 + nameBuf.length);
      const dvCd = new DataView(cd.buffer);
      dvCd.setUint32(0, 0x02014b50, true);
      dvCd.setUint16(4, 20, true);
      dvCd.setUint16(6, 20, true);
      dvCd.setUint16(8, 0, true);
      dvCd.setUint16(10, 0, true);
      dvCd.setUint16(12, 0, true);
      dvCd.setUint32(16, crc, true);
      dvCd.setUint32(20, size, true);
      dvCd.setUint32(24, size, true);
      dvCd.setUint16(28, nameBuf.length, true);
      dvCd.setUint16(30, 0, true);
      dvCd.setUint16(32, 0, true);
      dvCd.setUint16(34, 0, true);
      dvCd.setUint16(36, 0, true);
      dvCd.setUint32(38, 0, true);
      dvCd.setUint32(42, offset, true);
      cd.set(nameBuf, 46);
      cdHeaders.push(cd);

      offset += lh.length + dataBuf.length;
    }

    const cdOffset = offset;
    let cdSize = 0;
    for (const c of cdHeaders) cdSize += c.length;

    const eocd = new Uint8Array(22);
    const dvEo = new DataView(eocd.buffer);
    dvEo.setUint32(0, 0x06054b50, true);
    dvEo.setUint16(4, 0, true);
    dvEo.setUint16(6, 0, true);
    dvEo.setUint16(8, files.length, true);
    dvEo.setUint16(10, files.length, true);
    dvEo.setUint32(12, cdSize, true);
    dvEo.setUint32(16, cdOffset, true);
    dvEo.setUint16(20, 0, true);

    const allChunks = [...localHeaders, ...cdHeaders, eocd];
    let totalLength = 0;
    for (const c of allChunks) totalLength += c.length;
    const result = new Uint8Array(totalLength);
    let pos = 0;
    for (const c of allChunks) {
      result.set(c, pos);
      pos += c.length;
    }
    return result;
  }

  function escapeCsv(val) {
    if (val === null || val === undefined) return '';
    const str = String(val);
    if (str.includes(',') || str.includes('"') || str.includes('\n') || str.includes('\r')) {
      return '"' + str.replace(/"/g, '""') + '"';
    }
    return str;
  }

  function rgbListToAndroidInt(rgb) {
    if (!rgb || !Array.isArray(rgb) || rgb.length < 3) return -10902850;
    const r = Math.round((rgb[0] || 0) * 255);
    const g = Math.round((rgb[1] || 0) * 255);
    const b = Math.round((rgb[2] || 0) * 255);
    return ((0xff << 24) | (r << 16) | (g << 8) | b) >> 0;
  }

  async function fetchPngBytes(url) {
    if (!url) return null;
    try {
      const res = await fetch(url, { mode: 'cors' });
      const blob = await res.blob();
      const bitmap = await createImageBitmap(blob);
      const canvas = document.createElement('canvas');
      canvas.width = bitmap.width;
      canvas.height = bitmap.height;
      const ctx = canvas.getContext('2d');
      ctx.drawImage(bitmap, 0, 0);
      return new Promise((resolve) => {
        canvas.toBlob(async (b) => {
          resolve(b ? new Uint8Array(await b.arrayBuffer()) : null);
        }, 'image/png');
      });
    } catch {
      return null;
    }
  }

  const barcodeTypeMap = {
    14: 'QR_CODE',
    9: 'EAN_13',
    5: 'CODE_128',
    3: 'CODE_39',
    10: 'PDF_417',
  };

  console.log('searching for embedded pass data in script tags...');
  let passes = null;

  for (const s of document.querySelectorAll('script')) {
    const text = s.textContent || '';
    if (text.includes("AF_initDataCallback({key: 'ds:4'") || text.includes('AF_initDataCallback({key: "ds:4"')) {
      try {
        const start = text.indexOf('data:') + 'data:'.length;
        const end = text.lastIndexOf(', sideChannel:');
        if (start > 'data:'.length && end > start) {
          const raw = text.slice(start, end).trim();
          const parsed = JSON.parse(raw);
          if (Array.isArray(parsed) && Array.isArray(parsed[2])) {
            passes = parsed[2];
            break;
          }
        }
      } catch (err) {
        console.warn('failed to parse ds:4 data tag', err);
      }
    }
  }

  if (!passes || passes.length === 0) {
    alert('could not find pass data in page scripts. ensure https://wallet.google.com/wallet/passes is loaded');
    return;
  }

  console.log(`found ${passes.length} passes in embedded data, processing...`);
  const cards = [];

  for (let idx = 0; idx < passes.length; idx++) {
    const p = passes[idx];
    try {
      const card = p[0][0][1][0];
      const name = card[3][2];
      const barcode = String(card[4][0]).trim();
      const rawType = card[4][1][0];
      const btype = barcodeTypeMap[rawType] || (barcode.length === 13 ? 'EAN_13' : 'QR_CODE');
      const ts = card[2] && card[2][1] && card[2][1][0] ? card[2][1][0] : Math.floor(Date.now() / 1000);

      let colorVal = -10902850;
      try {
        if (card[15] && card[15][0] && card[15][0][1]) {
          colorVal = rgbListToAndroidInt(card[15][0][1]);
        }
      } catch {}

      let iconUrl = null;
      try {
        if (card[16] && card[16][1] && card[16][1][0]) {
          iconUrl = card[16][1][0];
        }
      } catch {}

      cards.push({
        id: idx + 1,
        name,
        barcode,
        type: btype,
        color: colorVal,
        ts,
        iconUrl,
      });
      console.log(`card [${idx + 1}/${passes.length}]: ${name} -> ${barcode} (${btype})`);
    } catch (e) {
      console.warn(`failed to parse pass at index ${idx}`, e);
    }
  }

  console.log(`successfully extracted ${cards.length} cards`);

  let csv =
    '2\n\n_id\n\n_id,store,note,validfrom,expiry,balance,balancetype,cardid,barcodeid,barcodetype,barcodeencoding,headercolor,starstatus,lastused,archive\n'; // editorconfig-checker-disable-line
  const zipFiles = [];

  for (const c of cards) {
    const row = [
      c.id,
      escapeCsv(c.name),
      '',
      '',
      '',
      '0',
      '',
      escapeCsv(c.barcode),
      '',
      c.type,
      'ISO-8859-1',
      c.color,
      0,
      c.ts,
      0,
    ];
    csv += row.join(',') + '\n';

    if (c.iconUrl) {
      const imgBytes = await fetchPngBytes(c.iconUrl);
      if (imgBytes) {
        zipFiles.push({ name: `card_${c.id}_icon.png`, data: imgBytes });
      }
    }
  }

  csv += '\ncardId,groupId\n';
  zipFiles.unshift({ name: 'catima.csv', data: new TextEncoder().encode(csv) });

  console.log('packaging into zip...');
  const zipBytes = makeZip(zipFiles);
  const blob = new Blob([zipBytes], { type: 'application/zip' });
  const a = document.createElement('a');
  a.href = URL.createObjectURL(blob);
  a.download = 'catima_19700101.zip';
  document.body.appendChild(a);
  a.click();
  document.body.removeChild(a);
  console.log('done, catima_19700101.zip downloaded');
})();
