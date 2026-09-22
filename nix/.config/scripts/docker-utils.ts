#!/usr/bin/env bun
import { bytes, capture, type Command, die, dispatch, exec, pickOne } from './lib/shell';

//? the same go template renders identically on docker and podman, while
//? --format json would need per-engine key fixups (ID/Id, Names as array)
const PS_FORMAT = '{{.Names}}\t{{.Image}}\t{{.Status}}';

//? no name given: pick one with fzf (the TODO from the sh version)
async function pickContainer(): Promise<string> {
  const rows = await capture(['docker', 'ps', '--format', PS_FORMAT]);
  if (!rows) die('No running containers.');

  const picked = await pickOne(rows.split('\n'), { args: ['--delimiter=\t'] });
  return picked?.split('\t')[0]?.trim() || die('Nothing selected.');
}

const resolve = async (arg?: string) => arg ?? (await pickContainer());

//! shell into a container, preferring bash
async function sh(name?: string) {
  const target = await resolve(name);
  return exec(['docker', 'exec', '-it', target, 'sh', '-c', 'bash || sh']);
}

//! same as sh, but carries the host aliases in
async function sha(name?: string) {
  const target = await resolve(name);

  //? a standalone script can't see the parent shell's aliases, so ask a fresh
  //? interactive zsh for them; session-local aliases are lost, rc ones are not
  const aliases = await capture(['zsh', '-ic', 'alias -L']);
  const rc = bytes(`[[ -f ~/.bashrc ]] && source ~/.bashrc\n${aliases}`);

  await capture(['docker', 'exec', '-i', target, 'bash', '-c', 'cat > /tmp/.custom_rc'], rc);

  return exec(['docker', 'exec', '-it', target, 'bash', '--rcfile', '/tmp/.custom_rc']);
}

//! follow compose logs, restarting the follow when the container dies
async function logs(...args: string[]) {
  for (;;) {
    await exec(['docker', 'compose', 'logs', '--tail', '1000', '-f', ...args]);
    console.log('Container stopped, restarting...');
    await Bun.sleep(1000);
  }
}

//! truncate every container's json log
async function clearLogs() {
  return exec(['sudo', 'sh', '-c', 'truncate -s 0 /var/lib/docker/containers/*/*-json.log']);
}

//! subcommand -> handler plus the short alias picked up by the generator
export const commands: Record<string, Command> = {
  sh: { alias: 'dcsh', run: sh, args: 'containers' },
  sha: { alias: 'dcsha', run: sha, args: 'containers' },
  logs: { alias: 'dclf', run: logs },
  'clear-logs': { alias: 'docker-clear-logs', run: clearLogs },
};

//? guard so the generator can import this file without running anything
if (import.meta.main) await dispatch(commands, 'docker-utils');
