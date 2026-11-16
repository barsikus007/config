{
  lib,
  pkgs,
  config,
  flakePath,
  ...
}:
let
  codePkg = pkgs.vscode;
  #! https://github.com/NixOS/nixpkgs/blob/c23193b943c6c689d70ee98ce3128239ed9e32d1/pkgs/applications/editors/vscode/generic.nix#L82
  # codePkg = pkgs.vscode-fhs
  editor = "code --wait";
  #? reuse single scratch window for external files in niri
  code-scratch = pkgs.writeShellScriptBin "code-scratch" ''
    id_file="''${XDG_RUNTIME_DIR:-/tmp}/code-scratch.id"
    scratch_id=""
    if [ -f "$id_file" ]; then
      scratch_id=$(${pkgs.coreutils}/bin/cat "$id_file")
    fi

    if ! ${lib.getExe pkgs.niri} msg --json windows >/dev/null 2>&1; then
      exec ${lib.getExe codePkg} --new-window "$@"
    fi

    if [ -n "$scratch_id" ] && ${lib.getExe pkgs.niri} msg --json windows | ${lib.getExe pkgs.jq} --exit-status --argjson id "$scratch_id" '.[] | select(.id == $id and .app_id == "code")' >/dev/null 2>&1; then
      ${lib.getExe pkgs.niri} msg action focus-window --id "$scratch_id"
      exec ${lib.getExe codePkg} --reuse-window "$@"
    fi

    existing_ids=$(${lib.getExe pkgs.niri} msg --json windows | ${lib.getExe pkgs.jq} --compact-output '[.[] | select(.app_id == "code") | .id]')

    ${lib.getExe codePkg} --new-window "$@" &

    for _ in {1..40}; do
      ${pkgs.coreutils}/bin/sleep 0.05
      new_id=$(${lib.getExe pkgs.niri} msg --json windows | ${lib.getExe pkgs.jq} --raw-output --argjson existing "$existing_ids" '.[] | select(.app_id == "code" and (.id as $id | $existing | contains([$id]) | not)) | .id' | ${pkgs.coreutils}/bin/head --lines=1)
      if [ -n "$new_id" ] && [ "$new_id" != "null" ]; then
        echo "$new_id" > "$id_file"
        break
      fi
    done
  '';
in
{
  custom.persist.home.directories = [
    ".config/Code"
    ".vscode"
    ".vscode-shared" # ? recent and trust folders
  ];

  xdg.configFile = {
    "Code/User/settings.json".source =
      config.lib.file.mkOutOfStoreSymlink "${flakePath}/.config/Code/User/settings.json";
    "Code/User/keybindings.json".source =
      config.lib.file.mkOutOfStoreSymlink "${flakePath}/.config/Code/User/keybindings.json";
  };
  programs.git.settings.core = { inherit editor; };
  home.sessionVariables = {
    SOPS_EDITOR = editor;
  };

  #? patch qwtel.sqlite-viewer extension to restore editing and disable pro paywall
  home.activation.patchSqliteViewer = lib.hm.dag.entryAfter [ "writeBoundary" ] /* python */ ''
    $DRY_RUN_CMD ${lib.getExe pkgs.python3} -I - <<'EOF'
    import glob, os

    home = os.environ.get("HOME")
    if home:
        dirs = glob.glob(os.path.join(home, ".vscode", "extensions", "qwtel.sqlite-viewer-*"))
        ext_replacements = [
            ("C=V&&nE?C0:r1", "C=r1"),
            (
                "function i0(e,c,t,s,{verified:n,accessToken:R,readOnly:j}){let v=n&&nE?k2:Fh;",
                "function i0(e,c,t,s,{verified:n,accessToken:R,readOnly:j}){let v=!j&&nE?k2:Fh;",
            ),
            (
                "get dbRemote(){return this.workerDb.dbRemote}get readOnly(){return this.workerDb.readOnly??!1}",
                "get dbRemote(){return this.workerDb.dbRemote}get readOnly(){return!1}",
            ),
            (
                'async refreshDb(){let t=this.dbRemote;if(await t.type==="wasm"){t[Symbol.dispose]();let{dbRemote:s,readOnly:n}=await this.createWorkerDb(this.uri,this.uriParts.filename);return this.workerDb={dbRemote:s,readOnly:n},s}return t}',
                "async refreshDb(){return this.dbRemote}",
            ),
            (
                "async save(t){await this.checkReadonly(),await this.#c.save(),this.instantCommit||await this.dbRemote.commit(mm(t))}",
                "async save(t){await this.checkReadonly(),await this.#c.save(),this.instantCommit||await this.dbRemote.commit(mm(t));try{let j=await this.dbRemote.exportDb(this.uriParts.filename);await pi.workspace.fs.writeFile(this.uri,j)}catch(e){console.error(e)}}",
            ),
        ]
        web_replacements = [
            ("var kt=yt,He=WB;", "var kt=yt,He=()=>!0;"),
            ("[WB,YB]=Te(!1)", "[WB,YB]=Te(!0)"),
            (
                "async function Pde(r){try{let{payload:e}=await VN(r,await pH,{});YB(!!e)}catch(e){throw console.error(e),e}}async function Mde(r){try{r&&await Pde(r)}catch(e){Lc(e)}}",
                "async function Pde(r){YB(!0)}async function Mde(r){YB(!0)}",
            ),
            ("get readWrite(){return wl()}", "get readWrite(){return!0}"),
            ("[wl,_B]=Te(!1)", "[wl,_B]=Te(!0)"),
            ("_B(e),CB(n)", "_B(!0),CB(n)"),
        ]
        for ext_dir in dirs:
            for file_path, reps in [
                (os.path.join(ext_dir, "out", "extension.js"), ext_replacements),
                (os.path.join(ext_dir, "sqlite-viewer-core", "vscode", "build", "assets", "index.js"), web_replacements),
            ]:
                if os.path.isfile(file_path):
                    with open(file_path, "r", encoding="utf-8") as f:
                        content = f.read()
                    mod = False
                    for old, new in reps:
                        if old in content:
                            content = content.replace(old, new, 1)
                            mod = True
                    if mod:
                        with open(file_path, "w", encoding="utf-8") as f:
                            f.write(content)
    EOF
  '';
  # TODO: extract as lib function (also from autostart)
  xdg.dataFile."applications/code-scratch.desktop".source =
    pkgs.runCommand "code-scratch.desktop" { }
      ''
        sed \
          -e 's|^Exec=code %F$|Exec=${lib.getExe code-scratch} %F|' \
          -e 's|^Name=Visual Studio Code$|Name=Visual Studio Code (Scratch)|' \
          ${codePkg}/share/applications/code.desktop > $out
      '';
  home.packages = [
    codePkg
    code-scratch
  ];
}
