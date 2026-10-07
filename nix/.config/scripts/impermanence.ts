#!/usr/bin/env bun
import { existsSync, lstatSync, readdirSync, readlinkSync, statSync } from 'node:fs';
import { join, relative, resolve } from 'node:path';
import { checkNixDir, hasSubmounts, readMountPoints } from './lib/fs';
import { c, type Command, die, dispatch, naturalCompare, parseCli } from './lib/shell';

type Status = 'orphaned' | 'nixStore' | 'persistent' | 'conflict' | 'submount' | 'volatile';

//? compare live directory against persistent counterpart
async function diff(...args: string[]): Promise<number> {
  const { flags, positionals } = parseCli(args, {
    name: 'pdiff',
    positional: '[path]',
    summary: 'compare directory against /persistent/ counterpart',
    flags: {
      all: { aliases: ['--all', '-a'], desc: 'show all entries including nix store and persistent' },
      shallow: { aliases: ['--shallow', '--max-depth=1'], desc: 'do not recurse into submount directories' },
    },
  });
  const target = positionals[0] ?? '.';
  const { all: showAll, shallow } = flags;

  const persistDev = statSync('/persistent', { throwIfNoEntry: false })?.dev ?? die('/persistent directory not found');
  const mounts = await readMountPoints();
  const abs = resolve(target);
  const isPersistPath = abs.startsWith('/persistent');
  const liveDir = isPersistPath ? abs.slice(11) || '/' : abs;
  const persistDir = isPersistPath ? abs : '/persistent' + abs;

  if (!existsSync(liveDir) && !existsSync(persistDir)) die(`path does not exist: ${abs}`);

  const checkItem = (
    lPath: string,
    pPath: string,
    inLive: boolean,
    inPersist: boolean,
  ): { status: Status; detail?: string } => {
    if (!inLive) return { status: 'orphaned' };
    const lst = lstatSync(lPath, { throwIfNoEntry: false });
    if (!lst) return { status: 'volatile' };

    if (lst.isSymbolicLink()) {
      try {
        const symTarget = readlinkSync(lPath);
        if (symTarget.includes('/nix/store/')) return { status: 'nixStore', detail: symTarget };
      } catch {}
      if (statSync(lPath, { throwIfNoEntry: false })?.dev === persistDev) return { status: 'persistent' };
      return { status: 'volatile' };
    }

    const st = statSync(lPath, { throwIfNoEntry: false });
    if (!st) return { status: 'volatile' };

    if (inPersist) {
      const pStat = statSync(pPath, { throwIfNoEntry: false });
      if (pStat && st.dev === persistDev && st.ino === pStat.ino) return { status: 'persistent' };
      if (lst.isDirectory() && hasSubmounts(lPath, mounts)) return { status: 'submount' };
      return { status: 'conflict' };
    }

    if (st.dev === persistDev) return { status: 'persistent' };
    if (lst.isDirectory()) {
      if (hasSubmounts(lPath, mounts)) return { status: 'submount' };
      const nix = checkNixDir(lPath);
      if (nix === 'all-nix') return { status: 'nixStore' };
      return { status: 'volatile', detail: nix === 'partial-nix' ? ' (partial nix)' : undefined };
    }
    return { status: 'volatile' };
  };

  const isSingleFile =
    (existsSync(liveDir) && !lstatSync(liveDir).isDirectory()) ||
    (!existsSync(liveDir) && existsSync(persistDir) && !lstatSync(persistDir).isDirectory());

  console.log(`${c.bold('live:')}    ${liveDir}${isSingleFile ? '' : '/'}`);
  console.log(`${c.bold('persist:')} ${persistDir}${isSingleFile ? '' : '/'}\n`);

  if (isSingleFile) {
    const { status, detail } = checkItem(liveDir, persistDir, existsSync(liveDir), existsSync(persistDir));
    if (status === 'nixStore') console.log(`${c.cyan('❄️ managed by nix store')} (symlink -> ${detail})`);
    else if (status === 'persistent') console.log(`${c.green('🔒 persistent')} (mounted from persistence)`);
    else if (status === 'conflict') {
      console.log(`${c.red('⚡ split conflict')} (exists in both, but not mounted; live will be lost on reboot)`);
    } else if (status === 'orphaned') {
      console.log(`${c.yellow('👻 orphaned in persistence')} (exists in /persistent/ but unmounted)`);
    } else console.log(`${c.red('⚠️ volatile')} (lives on rootfs, will be deleted on reboot)`);
    return 0;
  }

  if (!existsSync(liveDir)) {
    console.log(`${c.yellow('👻 orphaned directory in persistence')} (missing in live system)\n`);
    return 0;
  }
  if (statSync(liveDir).dev === persistDev) {
    console.log(`${c.green('status:')} entire directory is persistent (mounted from /persistent/)\n`);
    return 0;
  }

  const res = {
    conflict: [] as string[],
    orphaned: [] as string[],
    volatile: [] as string[],
    partial: [] as string[],
    nixStore: [] as string[],
    persistent: [] as string[],
  };

  const scan = (currLive: string, currPersist: string): void => {
    const liveEntries = new Set<string>();
    const persistEntries = new Set<string>();
    const names = new Set<string>();

    try {
      if (existsSync(currLive)) {
        for (const e of readdirSync(currLive)) {
          liveEntries.add(e);
          names.add(e);
        }
      }
    } catch {}

    try {
      if (existsSync(currPersist)) {
        for (const e of readdirSync(currPersist)) {
          persistEntries.add(e);
          names.add(e);
        }
      }
    } catch {}

    for (const name of names) {
      const lPath = join(currLive, name);
      const pPath = join(currPersist, name);
      const inLive = liveEntries.has(name);
      const inPersist = persistEntries.has(name);
      const isDir = inLive
        ? (lstatSync(lPath, { throwIfNoEntry: false })?.isDirectory() ?? false)
        : (statSync(pPath, { throwIfNoEntry: false })?.isDirectory() ?? false);
      const rel = relative(liveDir, lPath) + (isDir ? '/' : '');

      const { status, detail } = checkItem(lPath, pPath, inLive, inPersist);
      if (status === 'submount') {
        if (shallow) {
          let count = 0;
          for (const m of mounts) if (m === lPath || m.startsWith(lPath + '/')) count++;
          res.partial.push(`${rel} (${count} submount${count > 1 ? 's' : ''})`);
        } else {
          scan(lPath, pPath);
        }
      } else if (status === 'orphaned') res.orphaned.push(rel);
      else if (status === 'conflict') res.conflict.push(rel);
      else if (status === 'nixStore') res.nixStore.push(rel);
      else if (status === 'persistent') res.persistent.push(rel);
      else res.volatile.push(rel + (detail ?? ''));
    }
  };

  scan(liveDir, persistDir);
  for (const list of Object.values(res)) list.sort(naturalCompare);

  const printSection = (header: string, items: string[], format = (s: string) => s): void => {
    if (items.length === 0) return;
    console.log(header);
    for (const item of items) console.log(`  ${format(item)}`);
    console.log('');
  };

  printSection(c.red('⚡ split conflicts') + c.dim(' (unmounted in both, live lost on reboot):'), res.conflict, c.red);
  printSection(
    c.yellow('👻 orphaned in persistence') + c.dim(' (exists in /persistent/, not mounted):'),
    res.orphaned,
    c.yellow,
  );
  printSection(c.red('⚠️ volatile') + c.dim(' (unmounted on rootfs, lost on reboot):'), res.volatile);
  printSection(c.cyan('📦 partially mounted') + c.dim(' (rootfs dir with persistent submounts):'), res.partial);
  if (showAll) {
    printSection(c.cyan('❄️ nix store') + c.dim(' (home-manager declarative):'), res.nixStore, c.dim);
    printSection(c.green('🔒 persistent') + c.dim(' (mounted from /persistent/):'), res.persistent, c.green);
  }

  const parts = [
    res.conflict.length > 0 ? c.red(`${res.conflict.length} conflict`) : null,
    res.orphaned.length > 0 ? c.yellow(`${res.orphaned.length} orphaned`) : null,
    res.volatile.length > 0 ? c.red(`${res.volatile.length} volatile`) : null,
    res.partial.length > 0 ? c.cyan(`${res.partial.length} partial`) : null,
    c.dim(`${res.nixStore.length} nix`),
    c.green(`${res.persistent.length} persistent`),
  ].filter(Boolean);

  console.log(`${c.bold('summary:')} ${parts.join(', ')}`);
  if (!showAll && (res.nixStore.length > 0 || res.persistent.length > 0)) {
    console.log(c.dim('run with --all to view nix store and persistent entries'));
  }
  console.log('');
  return 0;
}

export const commands: Record<string, Command> = {
  diff: { alias: 'pdiff', extraAliases: ['persist-diff'], run: diff },
};

const rawArgs = process.argv.slice(2);
if (rawArgs.length === 0 || !commands[rawArgs[0]]) {
  process.argv = [process.argv[0], process.argv[1], 'diff', ...rawArgs];
}

if (import.meta.main) await dispatch(commands, 'impermanence');
