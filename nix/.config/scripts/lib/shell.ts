//! shared helpers for the scripts one level up
//? this directory holds no commands of its own, so the alias generator skips it

//? names a dynamic argument completer for zsh completion; each key is a zsh
//? snippet at lib/completions/<key>.zsh, inlined by the alias generator
export type ArgCompleter = 'containers' | 'adb-devices' | 'commands';

export type Command = {
  alias: string;
  run: (...args: string[]) => Promise<unknown>;
  args?: ArgCompleter;
  extraAliases?: string[];
};

//? the annotation belongs on the variable, not on the arrow: tsc only applies
//? never-narrowing when the const itself is typed, so `if (!x) die()` stops
//? narrowing x the moment someone "simplifies" this to `= (msg: string): never =>`
export const die: (msg: string) => never = (msg) => {
  console.error(msg);
  process.exit(1);
};

//! convert a string to bytes for passing into stdin
export const bytes = (s: string): Uint8Array => new TextEncoder().encode(s);

//! run an interactive command, inheriting the tty, and return its exit code
export function exec(argv: string[]): Promise<number> {
  return Bun.spawn(argv, { stdin: 'inherit', stdout: 'inherit', stderr: 'inherit' }).exited;
}

//! run a command and return its stdout with trailing newlines removed, exactly
//! what $(...) does in a shell; empty string when the command fails
export async function captureRaw(argv: string[], stdin?: string | Uint8Array): Promise<string> {
  const proc = Bun.spawn(argv, {
    stdin: stdin === undefined ? 'ignore' : typeof stdin === 'string' ? bytes(stdin) : stdin,
    stdout: 'pipe',
    stderr: 'ignore',
  });
  const out = await new Response(proc.stdout).text();
  return (await proc.exited) === 0 ? out.replace(/\n+$/, '') : '';
}

//! captureRaw with leading whitespace removed too, for reading a single value
//? use captureRaw when the leading blank lines are data, as in a screen dump
export async function capture(argv: string[], stdin?: string | Uint8Array): Promise<string> {
  return (await captureRaw(argv, stdin)).trim();
}

export type PickOptions = {
  prompt?: string;
  header?: string;
  multi?: boolean;
  preview?: string;
  //? fzf renders its ui on /dev/tty, so piping stdin and stdout is safe;
  //? every argument goes to spawn as one argv entry, which is why nothing here
  //? needs the quoting that --bind and --preview strings need in a shell
  args?: string[];
  //? by default an empty list skips fzf entirely; set this for the
  //? --disabled + start:reload pattern, where the list arrives after fzf starts
  allowEmpty?: boolean;
};

//! fzf over the given lines, returns every selected line
export async function pick(lines: string[], opts: PickOptions = {}): Promise<string[]> {
  if (lines.length === 0 && !opts.allowEmpty) return [];

  const argv = ['fzf', '--height=40%', '--reverse'];
  if (opts.prompt) argv.push(`--prompt=${opts.prompt}`);
  if (opts.header) argv.push(`--header=${opts.header}`);
  if (opts.multi) argv.push('--multi');
  if (opts.preview) argv.push(`--preview=${opts.preview}`);
  if (opts.args) argv.push(...opts.args);

  const proc = Bun.spawn(argv, {
    stdin: new TextEncoder().encode(lines.join('\n')),
    stdout: 'pipe',
    stderr: 'inherit',
  });
  const out = (await new Response(proc.stdout).text()).trim();
  await proc.exited;

  return out ? out.split('\n') : [];
}

//! fzf for exactly one line, skipping the prompt when there is nothing to choose
export async function pickOne(lines: string[], opts: PickOptions = {}): Promise<string | undefined> {
  if (lines.length === 1) return lines[0];
  return (await pick(lines, { ...opts, multi: false }))[0];
}

//! resolves to the host when tcp connect succeeds in time, undefined otherwise
//! a host that silently drops SYN leaves its connect pending forever, which keeps
//! the event loop alive; dispatch() calling process.exit is what ends it
export function probeTcp(host: string, port: number, ms = 500): Promise<string | undefined> {
  const conn = Bun.connect({
    hostname: host,
    port,
    socket: { data() {}, error() {}, close() {} },
  }).then(
    (socket) => {
      socket.end();
      return host;
    },
    () => undefined,
  );

  return Promise.race([conn, Bun.sleep(ms).then(() => undefined)]);
}

//! YYYY-MM-DD_HH-MM-SS in local time
export function timestamp(d = new Date()): string {
  const pad = (n: number) => String(n).padStart(2, '0');
  return (
    `${d.getFullYear()}-${pad(d.getMonth() + 1)}-${pad(d.getDate())}_` +
    `${pad(d.getHours())}-${pad(d.getMinutes())}-${pad(d.getSeconds())}`
  );
}

//! standard cli router for scripts
export async function dispatch(commands: Record<string, Command>, name: string): Promise<never> {
  const [cmd, ...rest] = process.argv.slice(2);
  const entry = commands[cmd ?? ''];
  if (!entry) die(`Usage: ${name} <${Object.keys(commands).join('|')}> [args]`);
  const code = Number(await entry.run(...rest)) || 0;
  process.exit(code);
}
