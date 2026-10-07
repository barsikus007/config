//! filesystem and mount helpers for scripts
import { lstatSync, readdirSync, readlinkSync } from 'node:fs';
import { join } from 'node:path';

//? parse active mountpoints from mountinfo
export async function readMountPoints(): Promise<Set<string>> {
  const mountinfo = await Bun.file('/proc/self/mountinfo').text();
  const mounts = new Set<string>();
  for (const line of mountinfo.split('\n')) {
    const parts = line.split(' ');
    if (parts.length >= 5) mounts.add(parts[4]!);
  }
  return mounts;
}

//? check if path contains submounts underneath
export function hasSubmounts(path: string, mounts: Set<string>): boolean {
  for (const m of mounts) {
    if (m !== path && m.startsWith(path + '/')) return true;
  }
  return false;
}

//? check if directory contains only nix store symlinks
export function checkNixDir(dirPath: string): 'all-nix' | 'partial-nix' | 'none' {
  try {
    const items = readdirSync(dirPath);
    if (items.length === 0) return 'none';
    let nixCount = 0;
    for (const item of items) {
      const p = join(dirPath, item);
      const lst = lstatSync(p);
      if (lst.isSymbolicLink()) {
        try {
          const target = readlinkSync(p);
          if (target.includes('/nix/store/')) nixCount++;
        } catch {}
      }
    }
    if (nixCount === items.length) return 'all-nix';
    if (nixCount > 0) return 'partial-nix';
    return 'none';
  } catch {
    return 'none';
  }
}
