// ==UserScript==
// @name         Video Link Dumper
// @namespace    https://github.com/barsikus007/
// @version      1.3
// @author       barsikus007
// @description  Dumps video links from players on animego.org
// @icon         https://www.google.com/s2/favicons?sz=64&domain=youtube.com
// @updateURL    https://raw.githubusercontent.com/barsikus007/config/master/browser/userscripts/VideoLinkDumper.user.js
// @downloadURL  https://raw.githubusercontent.com/barsikus007/config/master/browser/userscripts/VideoLinkDumper.user.js
// @match        https://aniboom.one/*
// @match        https://video.sibnet.ru/*
// @match        https://kodik.info/*
// ==/UserScript==

(async function () {
  let aniboomURL
  const videoElement = document.getElementById('video')
  try {
    aniboomURL = JSON.parse(JSON.parse(videoElement?.getAttribute('data-parameters'))?.dash)?.src
  } catch {}
  let sibnetURL = document.querySelector('video')?.src || ''
  const url = aniboomURL || (sibnetURL || undefined)
  if (!url) { return console.log('Failed to extract url') }
  sibnetURL = sibnetURL ? 'https://video.sibnet.ru' : ''
  let mpvBase = `mpv '${url}' --snap-window --no-border --save-position-on-quit --referrer='${sibnetURL}'`
  console.log('Just download with yt-dlp')
  // https://github.com/ytdl-org/youtube-dl/issues/15384#issuecomment-359654155
  console.log(`yt-dlp '${url}' --referer='${sibnetURL}' --no-part -N 16"`)
  console.log('or with aria2c')
  console.log(`yt-dlp '${url}' --referer='${sibnetURL}' --no-part --external-downloader aria2c --external-downloader-args "-x 16 -s 16 -k 1M"`)
  console.log('MPV max quality ("_" key for switch quality)')
  console.log(mpvBase)
  if (sibnetURL) { return }
  [1080, 720, 480].forEach((height) => {
    console.log(`MPV ${height}p (if available)`)
    console.log(`${mpvBase} --ytdl-raw-options=referer='' --ytdl-format='bestaudio+bestvideo[height<=?${height}]'`)
  })
})()
