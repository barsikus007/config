#!/usr/bin/env bun
//! markdown cheatsheet browser
//? two stages: pick a .md file under ~/config, then pick a heading inside it; typing
//? a query switches either stage from the plain listing to a live search instead
import { capture, type Command, die, dispatch, exec, pick } from './lib/shell';

const HOME = process.env.HOME ?? die('HOME is not set');
const CONFIG_DIR = `${HOME}/config`;
//? absolute path to this file, used to re-invoke it from inside fzf bind/preview actions
const SELF = import.meta.path;

//? file paths are spliced straight into a bind/preview action string that fzf hands to
//? $SHELL -c; unlike {q}/{1}/{2} placeholders, fzf does not quote that part for us
const shQuote = (s: string) => `'${s.replaceAll("'", `'\\''`)}'`;

//? typing a leading ' is fzf's own exact-match query syntax; --disabled mode never
//? filters locally, so this script has to strip it itself before using the query as a regex
const stripLeadingQuote = (q: string) => (q.startsWith("'") ? q.slice(1) : q);

//? bat highlights ```shell fences worse than ```bash ones. Done here in plain TS instead
//? of piping through sed with a pattern held in an env var (CHEAT_FENCE_SED in the shell
//? version), which only existed because fzf mangles a literal backtick embedded straight
//? in a --preview string
const fixFences = (content: string) => content.replace(/^```shell/gm, '```bash');

type Heading = { line: number; level: number; text: string };

//? replaces CHEAT_HEADING_AWK: headings outside fenced code blocks, so a "#" inside a
//? code comment is never mistaken for one
function listHeadings(content: string): Heading[] {
  const headings: Heading[] = [];
  const lines = content.split('\n');
  let inCode = false;
  for (let i = 0; i < lines.length; i++) {
    const line = lines[i]!;
    if (line.startsWith('```')) {
      inCode = !inCode;
      continue;
    }
    if (inCode) continue;
    const m = line.match(/^(#{1,6})\s/);
    if (m) headings.push({ line: i + 1, level: m[1]!.length, text: line });
  }
  return headings;
}

//? replaces CHEAT_SECTION_AWK: lines of the section starting at `start` (a heading of
//? `level`), stopping before the next heading of the same or shallower level; fenced
//? code blocks are skipped while looking for that next heading, same reasoning as above
function sectionLines(content: string, start: number, level: number): string[] {
  const lines = content.split('\n');
  const out: string[] = [lines[start - 1]!];
  let inCode = false;
  for (let i = start; i < lines.length; i++) {
    const line = lines[i]!;
    if (line.startsWith('```')) {
      inCode = !inCode;
    } else if (!inCode) {
      const m = line.match(/^(#{1,6})\s/);
      if (m && m[1]!.length <= level) break;
    }
    out.push(line);
  }
  return out;
}

//? cheatsheet files first, then the rest; fzf keeps this order as-is when there is no
//? query. A single fd call plus two TS filters replaces the shell version's two
//? independent fd runs (one piped through rg's match, one through its invert-match)
async function listCheatFiles(): Promise<string[]> {
  const files = (await capture(['fd', '--extension', 'md', '.', CONFIG_DIR])).split('\n').filter(Boolean);
  const isSheet = (f: string) => /cheatsheet/i.test(f);
  return [...files.filter(isSheet), ...files.filter((f) => !isSheet(f))];
}

//! hidden: stage-1 reload target, listing files or grepping their content for a query
async function searchFiles(query = '') {
  if (!query) {
    console.log((await listCheatFiles()).join('\n'));
    return;
  }
  const q = stripLeadingQuote(query);
  await exec([
    'rg',
    '--line-number',
    '--no-heading',
    '--smart-case',
    '--color=never',
    '--glob',
    '*.md',
    '--',
    q,
    CONFIG_DIR,
  ]);
}

//! hidden: stage-1 preview, a matched line in context or the whole file
async function previewFile(file = '', line = '') {
  if (line) {
    await exec([
      'bat',
      '--style=numbers',
      '--color=always',
      '--highlight-line',
      line,
      '--line-range',
      `${line}:`,
      file,
    ]);
    return;
  }
  const content = fixFences(await Bun.file(file).text());
  console.log(await capture(['bat', '--style=numbers', '--color=always', '--language=markdown'], content));
}

//? replaces the shell version's CHEAT_SEARCH_SH temp script. fzf's --bind parser
//? garbles command strings once nested quotes/regex get complex enough (seen it mangle
//? results, not just cosmetics), which is why that version wrote a real script file at
//? runtime instead of inlining the pipeline; re-invoking this script as a hidden
//? subcommand is the same escape hatch, done once, ahead of time, in TS
async function searchInFile(file: string, query: string): Promise<string[]> {
  const headingRows = listHeadings(await Bun.file(file).text()).map((h) => `${h.line}:${h.level}:${h.text}`);
  const matchedHeadings = await capture(['rg', '--smart-case', '--color=never', '--', query], headingRows.join('\n'));
  const out = matchedHeadings ? matchedHeadings.split('\n') : [];

  const bodyHits = await capture([
    'rg',
    '--line-number',
    '--no-heading',
    '--smart-case',
    '--color=never',
    '--',
    query,
    file,
  ]);
  for (const hit of bodyHits ? bodyHits.split('\n') : []) {
    //? skip body hits that are just a heading already listed above
    if (/^\d+:#{1,6}\s/.test(hit)) continue;
    out.push(hit.replace(':', ':-:'));
  }
  return out;
}

//! hidden: stage-2 reload target, listing headings or searching within one file
async function searchHeadings(file = '', query = '') {
  if (!query) {
    const rows = listHeadings(await Bun.file(file).text()).map((h) => `${h.line}:${h.level}:${h.text}`);
    console.log(rows.join('\n'));
    return;
  }
  const rows = await searchInFile(file, stripLeadingQuote(query));
  console.log(rows.join('\n'));
}

//! hidden: stage-2 preview, a bounded section for a heading row or a line in context
//? for a body hit ("-" in place of a level)
async function previewSection(file = '', line = '', level = '') {
  if (/^\d+$/.test(level)) {
    const section = fixFences(sectionLines(await Bun.file(file).text(), Number(line), Number(level)).join('\n'));
    console.log(await capture(['bat', '--style=plain', '--color=always', '--language=markdown'], section));
    return;
  }
  await exec(['bat', '--style=numbers', '--color=always', '--highlight-line', line, '--line-range', `${line}:`, file]);
}

//! browse markdown cheatsheets under ~/config, then jump to the pick in nvim
async function cheats() {
  //? the list arrives from the start:reload bind, not from stdin, so fzf has to
  //? run even though nothing is piped in
  const sel = (
    await pick([], {
      allowEmpty: true,
      prompt: 'Cheatsheet> ',
      preview: `${SELF} preview-file {1} {2}`,
      args: [
        '--disabled',
        '--ansi',
        '--delimiter=:',
        `--bind=start,change:reload:${SELF} search-files {q} || :`,
        '--preview-window=right:60%',
      ],
    })
  )[0];
  if (!sel) return;

  const fields = sel.split(':');
  if (fields.length >= 3) {
    //? content-search hit ("path:line:text"), jump straight to the matched line
    await exec(['nvim', `+${fields[1]}`, fields[0]!]);
    return;
  }
  const file = sel;

  const sel2 = (
    await pick([], {
      allowEmpty: true,
      prompt: 'Section> ',
      preview: `${SELF} preview-section ${shQuote(file)} {1} {2}`,
      args: [
        '--disabled',
        '--ansi',
        '--delimiter=:',
        '--with-nth=3..',
        `--bind=start,change:reload:${SELF} search-headings ${shQuote(file)} {q} || :`,
        '--preview-window=right:60%',
      ],
    })
  )[0];
  if (sel2) await exec(['nvim', `+${sel2.split(':')[0]}`, file]);
}

//! subcommand -> handler plus the short alias picked up by the generator; entries with
//! an empty alias are re-invocation targets for fzf's --bind/--preview, not user commands
export const commands: Record<string, Command> = {
  cheats: { alias: 'cheats', run: cheats },
  'search-files': { alias: '', run: searchFiles },
  'search-headings': { alias: '', run: searchHeadings },
  'preview-file': { alias: '', run: previewFile },
  'preview-section': { alias: '', run: previewSection },
};

//? guard so the generator can import this file without running anything
if (import.meta.main) await dispatch(commands, 'cheats');
