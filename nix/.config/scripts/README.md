# scripts

standalone executables for complex situations

## why

- for string parsing
- for failsafe
- for concurrency
- for convinient reusable functions

## what belongs here

put a script here when it does two or more of these:

- parses structured output (JSON, columns, key-value pairs)
- loops over items and handles the failure of one item
- runs work in parallel
- validates arguments and prints a usage message
- keeps state that it must clean up

keep it in `../shell/` when either of these is true:

- it changes the interactive shell
- it is small task

## aliases

each script owns its short names. the `commands` table maps a subcommand to its alias and its handler:

```ts
export const commands: Record<string, Command> = {
  sh: { alias: "dcsh", run: sh },
};
```

the [pre-commit hook](../../hooks/compile-script-aliases.ts) reads that table from every `*.ts` file here.
it writes [script-aliases.sh](../shell/script-aliases.sh), which the shell sources with the rest of [shell directory](../shell/).
the output file is generated, so it is not in git.
to write it without a commit, run the hook from the repo root:

```shell
prek run compile-script-aliases-from-ts --all-files
```

## completions

the same hook writes `completions/_<name>` for zsh, from the same table.
subcommand names complete on `docker-utils.ts <tab>`, and an alias completes the arguments of its subcommand, so `dcsh <tab>` offers containers.
an entry can name a dynamic completer with `args` (`containers`, `adb-devices`, `commands`); each name is a zsh snippet at `lib/completions/<name>.zsh`, the hook inlines it.
entries with `alias: ""` stay hidden. zsh finds the files through fpath, wired in `nix/home/shell/minimal.nix`. on bash only the subcommand names complete, through the `complete -W` block in `script-aliases.sh`.
