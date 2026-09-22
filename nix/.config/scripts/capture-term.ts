#!/usr/bin/env bun
//! capture one command's terminal output as a floating wezterm window and screenshot it
import { rm } from 'node:fs/promises';
import { homedir } from 'node:os';
import { capture, captureRaw, dispatch, exec, timestamp, type Command } from './lib/shell';

//! run a command once in a hidden tmux pane, size a floating wezterm window to
//! fit what it printed, replay the output there, and screenshot that window
async function captureWeztermZshCmd(...args: string[]): Promise<number> {
  //? how long to let the command run before screenshotting; short commands are
  //? captured as soon as they finish, interactive/never-exiting apps (htop,
  //? vim, ...) are captured once this elapses, bump it for slow commands
  let timeout = 3;

  //? everything after -t/--timeout is the command, so multi-word invocations
  //? work unquoted (e.g. capture_wezterm_zsh_cmd cat ~/smth)
  let i = 0;
  while (args[i]?.startsWith('-')) {
    switch (args[i]) {
      case '-t':
      case '--timeout':
        timeout = Number(args[i + 1]);
        i += 2;
        break;
      default:
        console.log(`Unknown option: ${args[i]}`);
        return 1;
    }
  }
  const cmd = args.slice(i).join(' ');

  if (!cmd) {
    console.log('Error: no command given.');
    return 1;
  }

  if (!Bun.which('tmux')) {
    console.log('Error: tmux is required to measure the 2D geometry.');
    return 1;
  }

  console.log('Rendering output in tmux (command runs exactly once)...');

  const pid = process.pid;
  const session = `wez_measure_${pid}`;
  const dumpColored = `/tmp/wez_dump_${pid}.ansi`;
  const doneFile = `/tmp/wez_done_${pid}`;

  //? true once the wezterm window has taken ownership of dumpColored (it cats
  //? the file, sleeps, then removes it itself); cleared on failure so the
  //? finally block below removes the file instead of leaking it
  let handedOff = false;

  try {
    //? zsh -i loads the interactive config (aliases, functions, colors, the
    //? real PS1) and prints the actual prompt + command before running it
    //? exactly once; inside a pty the zle/precmd hooks work without errors and
    //? eval expands aliases; cmd and the marker path travel through the tmux
    //? session environment (-e) instead of being interpolated into the pane
    //? script, so nothing here needs shell quoting and nothing leaks into the
    //? parent shell; once the command finishes it touches the marker file,
    //? then the pane sleeps so there is still time left to grab the screen
    await exec([
      'tmux',
      'new-session',
      '-d',
      '-s',
      session,
      '-x',
      '240',
      '-y',
      '80',
      '-e',
      `CMD_TO_RUN=${cmd}`,
      '-e',
      `DONE_FILE=${doneFile}`,
      `zsh -i -c 'print -Pn "$PS1"; echo " $CMD_TO_RUN"; eval "$CMD_TO_RUN"; touch "$DONE_FILE"; sleep 600'`,
    ]);

    //? wait for the command to finish or the time limit to elapse, whichever
    //? comes first; interactive apps never create the marker, so the limit is
    //? what lets us screenshot them once they have rendered
    const deadline = Date.now() + timeout * 1000;
    while (!(await Bun.file(doneFile).exists())) {
      if (Date.now() >= deadline) break;
      await Bun.sleep(100);
    }

    //? plain-text dump, used only to measure the geometry
    //? captureRaw, not capture: leading blank lines are data here, trimming them
    //? would shift every row index below
    const screenDump = await captureRaw(['tmux', 'capture-pane', '-p', '-t', session]);
    const lines = screenDump.split('\n');

    //? last non-empty line number, trims the empty blackness at the bottom
    let rows = 0;
    lines.forEach((line, idx) => {
      if (/\S/.test(line)) rows = idx + 1;
    });
    if (rows === 0) rows = 1;

    //? display width, not character count: the shell version used
    //? wc --max-line-length, which counts terminal cells, so a cjk line measures
    //? twice its .length and a window sized by .length comes out too narrow
    let cols = Math.max(0, ...lines.map((line) => Bun.stringWidth(line)));

    //? padding in cells, needed for two reasons: a space-only line looks empty
    //? to the row scan above, yet the colored dump may still carry a
    //? background fill there, so without slack such lines get clipped; and it
    //? gives the text a margin so it does not touch the window edges
    const pad = 4;

    //? tmux numbers lines from 0, so the last content line is (rows - 1); add
    //? pad lines of slack below it
    const coloredDump = await captureRaw([
      'tmux',
      'capture-pane',
      '-e',
      '-p',
      '-t',
      session,
      '-S',
      '0',
      '-E',
      String(rows - 1 + pad),
    ]);
    await Bun.write(dumpColored, coloredDump);

    //? window geometry = content + the same margin on each side
    rows += pad;
    cols += pad;

    //! no clamp here on purpose: the shell version carried one commented out
    //! (rows 5-60, cols 40-240) and it contradicts this same function, which
    //! opens the pane at -x 240 -y 80; capping rows at 60 cut every window
    //! taller than 56 rows while the colored dump still held all 84 lines

    console.log(`Chosen size: ${cols} columns, ${rows} rows. Launching WezTerm...`);

    //? open wezterm sized to fit; instead of running the command again it just
    //? prints the colored dump and waits, so the command still runs exactly once
    try {
      void exec([
        'wezterm',
        '--config',
        `initial_cols=${cols}`,
        '--config',
        `initial_rows=${rows}`,
        'start',
        '--always-new-process',
        '--class',
        'org.wezfurlong.wezterm.floating',
        '--',
        'zsh',
        '-c',
        `cat "${dumpColored}"; sleep 2; rm -f "${dumpColored}"`,
      ]);
      handedOff = true;
    } catch {
      // wezterm never started, dumpColored is removed by the finally block below
    }

    //? give the window manager time to draw the window
    await Bun.sleep(2000);

    if (process.env.XDG_CURRENT_DESKTOP?.includes('KDE')) {
      await exec(['spectacle', '--activewindow', '--background']);
      console.log('Window screenshot (KDE) saved.');
    } else if (Bun.which('niri')) {
      await exec(['niri', 'msg', 'action', 'screenshot-window']);
      console.log('Window screenshot (Niri) taken.');
    } else {
      const path = `${homedir()}/Pictures/Screenshots/wezterm_exec_${timestamp()}.png`;
      await exec(['grim', path]);
      console.log('Screenshot taken via grim.');
    }

    return 0;
  } finally {
    await rm(doneFile, { force: true });
    await capture(['tmux', 'kill-session', '-t', session]);
    if (!handedOff) await rm(dumpColored, { force: true });
  }
}

//! subcommand -> handler plus the short alias picked up by the generator
export const commands: Record<string, Command> = {
  run: { alias: 'capture_wezterm_zsh_cmd', run: captureWeztermZshCmd, args: 'commands' },
};

//? guard so the generator can import this file without running anything
if (import.meta.main) await dispatch(commands, 'capture-term');
