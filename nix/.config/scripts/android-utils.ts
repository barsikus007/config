#!/usr/bin/env bun
import { existsSync } from 'node:fs';
import { capture, die, dispatch, exec, pickOne, probeTcp, type Command } from './lib/shell';

const ADB_PORT = 5555;
const PROBE_MS = 500;

//? no serial given: pick one with fzf, dropping the header line adb devices prints first
async function pickAndroidDevice(): Promise<string> {
  const rows = await capture(['adb', 'devices']);
  const lines = rows.split('\n').slice(1).filter(Boolean);
  const picked = await pickOne(lines);

  return picked?.split(/\s+/)[0] || die('No device selected');
}

const resolveDevice = async (serial?: string) => serial ?? (await pickAndroidDevice());

//? prefer the interface used by the default route, fall back to the first global one
async function findInterface(): Promise<string> {
  const route = await capture(['ip', '-o', '-4', 'route', 'show', 'default']);
  const routeFields = route.split('\n')[0].split(/\s+/);
  const devIndex = routeFields.indexOf('dev');
  if (devIndex !== -1 && routeFields[devIndex + 1]) return routeFields[devIndex + 1];

  const addr = await capture(['ip', '-o', '-4', 'addr', 'show', 'scope', 'global']);
  return addr.split('\n')[0].split(/\s+/)[1] ?? '';
}

//? scan local subnet for hosts with adb port 5555 open
async function adbScan(): Promise<string[]> {
  const iface = await findInterface();
  if (!iface) die('Error: Could not determine local interface');

  const addr = await capture(['ip', '-o', '-f', 'inet', 'addr', 'show', iface]);
  const subnet = addr.split('\n')[0].split(/\s+/)[3];
  if (!subnet) die(`Error: Could not determine local subnet on interface ${iface}`);

  const prefix = subnet.split('/')[0].split('.').slice(0, 3).join('.');
  console.error(`Scanning ${subnet} on ${iface} for ADB devices (port ${ADB_PORT})...`);

  const hosts = Array.from({ length: 254 }, (_, i) => `${prefix}.${i + 1}`);

  //? measured on a /24: nc with a pool of 32 takes 4044 ms, nc unpooled 668 ms,
  //? this 512 ms; a bounded pool is wrong here because it turns one per-host
  //? timeout into eight sequential waves of it
  const found = await Promise.all(hosts.map((host) => probeTcp(host, ADB_PORT, PROBE_MS)));

  return found.filter((host): host is string => host !== undefined);
}

//? print one ip per line, matching adb_scan's original stdout contract
async function scan() {
  for (const ip of await adbScan()) console.log(ip);
}

async function connect() {
  const found = await adbScan();
  if (found.length === 0) {
    console.log(`No devices found with port ${ADB_PORT} open`);
    return 0;
  }

  const selected =
    (await pickOne(
      found.map((ip) => `${ip}:${ADB_PORT}`),
      { prompt: 'ADB device> ' },
    )) || die('Nothing selected.');

  return exec(['adb', 'connect', selected]);
}

async function disconnect(serial?: string) {
  const device = await resolveDevice(serial);
  return exec(['adb', 'disconnect', device]);
}

async function shellAsRoot(serial?: string) {
  const device = await resolveDevice(serial);
  return exec(['adb', '-s', device, 'shell', '-t', 'su --command /data/data/com.termux/files/home/.adbrc']);
}

async function shellAsTermux(serial?: string) {
  const device = await resolveDevice(serial);
  return exec([
    'adb',
    '-s',
    device,
    'shell',
    '-t',
    'su $(su --command "stat --format %U /data/data/com.termux") --command /data/data/com.termux/files/home/.adbrc',
  ]);
}

async function shellAsNix(serial?: string) {
  const device = await resolveDevice(serial);
  return exec([
    'adb',
    '-s',
    device,
    'shell',
    '-t',
    'su $(su --command "stat --format %U /data/data/com.termux.nix") --command /data/data/com.termux.nix/files/usr/bin/login', // editorconfig-checker-disable-line
  ]);
}

async function fsConnect(serial?: string) {
  const device = await resolveDevice(serial);

  const lines = (await capture(['adb', 'devices', '-l'])).split('\n');
  const devLine = lines.find((l) => l.startsWith(device));
  const modelMatch = devLine?.match(/model:(\S+)/);
  const model = modelMatch?.[1] || device;

  const user = process.env.USER ?? die('USER is not set');
  const baseFolder = `/run/media/${user}/adbfs`;

  if (!existsSync(baseFolder)) {
    await exec(['sudo', 'mkdir', '--parents', baseFolder]);
    const uid = await capture(['id', '--user']);
    const gid = await capture(['id', '--group']);
    await exec(['sudo', 'chown', `${uid}:${gid}`, baseFolder]);
  }

  const deviceFolder = `${baseFolder}/${model}`;
  console.error(`Device folder: ${deviceFolder}`);

  console.error('Unmounting...');
  await capture(['umount', deviceFolder]);
  await exec(['mkdir', '--parents', deviceFolder]);

  const uid = await capture(['id', '--user']);
  const gid = await capture(['id', '--group']);
  const code = await exec(['adbfs', deviceFolder, '-o', `uid=${uid},gid=${gid}`]);
  if (code !== 0) die('adbfs mount failed');

  console.log(`${deviceFolder}/storage/emulated/0/`);
  return 0;
}

async function fsConnected() {
  const folder = `/run/media/${process.env.USER ?? ''}/adbfs`;
  return exec(['ls', '--format=single-column', folder]);
}

async function fsDisconnect() {
  const mounts = await capture(['mount']);
  const lines = mounts.split('\n').filter((line) => line.includes('adbfs'));
  const picked = (await pickOne(lines)) || die('No mount selected');

  //? mount prints "<device> on <path> type <fstype> (<options>)", path is field 3
  const path = picked.split(/\s+/)[2];

  await exec(['pgrep', '--full', path]);
  return exec(['umount', path]);
}

async function scrcpyConnect(...args: string[]) {
  const device = await resolveDevice();
  return exec([
    'scrcpy',
    '--keyboard=uhid',
    '--render-driver=opengles2',
    '--no-audio',
    '--video-bit-rate=1M',
    `--serial=${device}`,
    ...args,
  ]);
}

//? connect to the first and only device, no picker
async function scrcpyFast(...args: string[]) {
  const rows = await capture(['adb', 'devices']);
  const lines = rows.split('\n').slice(1).filter(Boolean);
  const online = lines.find((line) => line.split(/\s+/)[1] === 'device');
  let serial = online?.split(/\s+/)[0];

  //? nothing connected: scan the network and auto-connect to the first found
  if (!serial) {
    const first = (await adbScan())[0];
    if (!first) die('No device connected or found');
    serial = `${first}:${ADB_PORT}`;
    const code = await exec(['adb', 'connect', serial]);
    if (code !== 0) return code;
  }

  return exec([
    'scrcpy',
    '--keyboard=uhid',
    '--render-driver=opengles2',
    '--no-audio',
    '--video-bit-rate=1M',
    `--serial=${serial}`,
    ...args,
  ]);
}

async function scrcpyCamera(...args: string[]) {
  const device = await resolveDevice();
  await exec(['sudo', 'v4l2loopback-ctl', 'add', '--name', 'scrcpy Cam', '/dev/video9']);
  return exec([
    'scrcpy',
    '--render-driver=opengles2',
    '--video-source=camera',
    '--no-audio',
    '--v4l2-sink=/dev/video9',
    '--camera-id=0',
    '--camera-size=2048x1536',
    '--capture-orientation=90',
    // '--camera-id=1',
    // '--camera-size=1640x1232',
    // '--capture-orientation=270',
    // '--camera-id=2',
    // '--camera-size=2048x1536',
    // '--capture-orientation=90',
    // '--camera-id=3',
    // '--camera-size=2048x1536',
    // '--capture-orientation=90',
    '--no-window',
    `--serial=${device}`,
    ...args,
  ]);
  // [server] ERROR: Camera with id 5 not found
  // List of cameras:
  //     --camera-id=0    (back, 4096x3072, fps={10, 15, 22, 24, 30, 60}, zoom-range=[0.67, 20])
  //     --camera-id=1    (front, 3280x2464, fps={10, 15, 22, 24, 30, 60}, zoom-range=[1, 10])
  //     --camera-id=2    (back, 4096x3072, fps={10, 15, 22, 24, 30, 60}, zoom-range=[1, 10])
  //     --camera-id=3    (back, 4096x3072, fps={10, 15, 22, 24, 30, 60}, zoom-range=[1, 10])
  //     --camera-id=4    (back, 4096x3072, fps={10, 15, 22, 24, 30, 60}, zoom-range=[1, 10])
  // ERROR: Demuxer 'video': stream disabled due to connection error
  // WARN: Device disconnected
}

async function scrcpyCameraFfmpeg() {
  await exec(['sudo', 'v4l2loopback-ctl', 'add', '--name', 'ffmpeg Cam', '/dev/video10']);
  return exec([
    'ffmpeg',
    '-f',
    'v4l2',
    '-i',
    '/dev/video9',
    '-vf',
    'transpose=1,format=yuv420p',
    '-f',
    'v4l2',
    '/dev/video10',
  ]);
}

//! subcommand -> handler plus the original shell function name kept as the alias
export const commands: Record<string, Command> = {
  scan: { alias: 'adb_scan', run: scan },
  connect: { alias: 'adb_connect', run: connect },
  disconnect: { alias: 'adb_disconnect', run: disconnect, args: 'adb-devices' },
  'shell-root': { alias: 'adb_shell_as_root', run: shellAsRoot, args: 'adb-devices' },
  'shell-termux': { alias: 'adb_shell_as_termux', run: shellAsTermux, args: 'adb-devices' },
  'shell-nix': { alias: 'adb_shell_as_nix', run: shellAsNix, args: 'adb-devices' },
  'fs-connected': { alias: 'adbfs_connected', run: fsConnected },
  'fs-connect': {
    alias: 'adbfs_connect',
    run: fsConnect,
    args: 'adb-devices',
    extraAliases: ['adbfs_yazi'],
  },
  'fs-disconnect': { alias: 'adbfs_disconnect', run: fsDisconnect },
  scrcpy: { alias: 'scrcpy_connect', run: scrcpyConnect },
  'scrcpy-fast': { alias: 'scrcpy_fast', run: scrcpyFast },
  'scrcpy-camera': { alias: 'scrcpy_camera', run: scrcpyCamera },
  'scrcpy-camera-ffmpeg': { alias: 'scrcpy_camera_ffmpeg', run: scrcpyCameraFfmpeg },
};

//? guard so the generator can import this file without running anything
if (import.meta.main) await dispatch(commands, 'android-utils');
