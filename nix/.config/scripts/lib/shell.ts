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

//! ansi color formatting for terminal output
const isTty = process.stdout.isTTY;
export const c = {
  bold: (s: string) => (isTty ? `\x1b[1m${s}\x1b[0m` : s),
  red: (s: string) => (isTty ? `\x1b[31m${s}\x1b[0m` : s),
  yellow: (s: string) => (isTty ? `\x1b[33m${s}\x1b[0m` : s),
  green: (s: string) => (isTty ? `\x1b[32m${s}\x1b[0m` : s),
  cyan: (s: string) => (isTty ? `\x1b[36m${s}\x1b[0m` : s),
  dim: (s: string) => (isTty ? `\x1b[2m${s}\x1b[0m` : s),
};

//! case-insensitive and dot-neutral natural path and string sorting
export function naturalCompare(a: string, b: string): number {
  const aParts = a.split('/');
  const bParts = b.split('/');
  const len = Math.min(aParts.length, bParts.length);
  for (let i = 0; i < len; i++) {
    const aSeg = aParts[i]!;
    const bSeg = bParts[i]!;
    if (aSeg === bSeg) continue;
    const aNorm = aSeg.replace(/^\./, '');
    const bNorm = bSeg.replace(/^\./, '');
    const cmp = aNorm.localeCompare(bNorm, 'en', { sensitivity: 'base', numeric: true });
    if (cmp !== 0) return cmp;
    return aSeg.localeCompare(bSeg, 'en');
  }
  return aParts.length - bParts.length;
}

export type FlagOptionDef = string | string[] | { aliases: string | string[]; desc?: string };

export type CliConfig<F extends string = string, O extends string = string> = {
  name?: string;
  summary?: string;
  positional?: string;
  usage?: string;
  stopAtPositional?: boolean;
  flags?: Record<F, FlagOptionDef>;
  options?: Record<O, FlagOptionDef>;
};

function extractAliases(def: FlagOptionDef, fallbackKey: string): { aliases: string[]; desc?: string } {
  if (Array.isArray(def)) return { aliases: def };
  if (typeof def === 'string') return { aliases: [def] };
  if (def && typeof def === 'object') {
    const a = Array.isArray(def.aliases) ? def.aliases : [def.aliases ?? fallbackKey];
    return { aliases: a, desc: def.desc };
  }
  return { aliases: [fallbackKey] };
}

//! generate usage string from cli configuration
export function buildUsage(config: CliConfig): string {
  if (config.usage) return config.usage;
  const name = config.name ?? 'command';
  const pos = config.positional ? ` ${config.positional}` : '';
  const flagTokens: string[] = [];
  const optTokens: string[] = [];
  const descriptions: string[] = [];

  for (const [key, def] of Object.entries(config.flags ?? {})) {
    const { aliases, desc } = extractAliases(def as FlagOptionDef, key);
    flagTokens.push(`[${aliases.join('|')}]`);
    if (desc) descriptions.push(`  ${aliases.join(', ').padEnd(24)} ${desc}`);
  }

  for (const [key, def] of Object.entries(config.options ?? {})) {
    const { aliases, desc } = extractAliases(def as FlagOptionDef, key);
    optTokens.push(`[${aliases.join('|')} <val>]`);
    if (desc) descriptions.push(`  ${aliases.map((a) => `${a} <val>`).join(', ').padEnd(24)} ${desc}`);
  }

  const parts = [flagTokens.join(' '), optTokens.join(' ')].filter(Boolean);
  const flagsStr = parts.length > 0 ? ` ${parts.join(' ')}` : '';
  let out = `usage: ${name}${pos}${flagsStr}`;
  if (config.summary) out += `\n\n${config.summary}`;
  if (descriptions.length > 0) out += `\n\noptions:\n${descriptions.join('\n')}`;
  return out;
}

//! lightweight cli argument and flag parser for scripts
export function parseCli<F extends string = string, O extends string = string>(
  args: string[],
  config: CliConfig<F, O> = {},
): { flags: Record<F, boolean>; options: Record<O, string | undefined>; positionals: string[] } {
  const flags = {} as Record<F, boolean>;
  const options = {} as Record<O, string | undefined>;
  const positionals: string[] = [];
  const usage = buildUsage(config as CliConfig);

  const flagMap = new Map<string, F>();
  for (const [key, def] of Object.entries(config.flags ?? {}) as [F, FlagOptionDef][]) {
    flags[key] = false;
    const { aliases } = extractAliases(def, key);
    for (const a of aliases) flagMap.set(a, key);
  }

  const optMap = new Map<string, O>();
  for (const [key, def] of Object.entries(config.options ?? {}) as [O, FlagOptionDef][]) {
    const { aliases } = extractAliases(def, key);
    for (const a of aliases) optMap.set(a, key);
  }

  for (let i = 0; i < args.length; i++) {
    const arg = args[i]!;
    if (arg === '--') {
      positionals.push(...args.slice(i + 1));
      break;
    }

    if (arg === '-h' || arg === '--help') {
      console.log(usage);
      process.exit(0);
    }

    if (flagMap.has(arg)) {
      flags[flagMap.get(arg)!] = true;
      continue;
    }

    const eqIdx = arg.indexOf('=');
    if (eqIdx !== -1) {
      const optName = arg.slice(0, eqIdx);
      if (optMap.has(optName)) {
        options[optMap.get(optName)!] = arg.slice(eqIdx + 1);
        continue;
      }
    }

    if (optMap.has(arg)) {
      const next = args[++i];
      if (next !== undefined) options[optMap.get(arg)!] = next;
      continue;
    }

    if (config.stopAtPositional && !arg.startsWith('-')) {
      positionals.push(...args.slice(i));
      break;
    }

    if (!arg.startsWith('-')) {
      positionals.push(arg);
    }
  }

  return { flags, options, positionals };
}

//! standard cli router for scripts
export async function dispatch(commands: Record<string, Command>, name: string): Promise<never> {
  const [cmd, ...rest] = process.argv.slice(2);
  const entry = commands[cmd ?? ''];
  if (!entry) die(`Usage: ${name} <${Object.keys(commands).join('|')}> [args]`);
  const code = Number(await entry.run(...rest)) || 0;
  process.exit(code);
}
