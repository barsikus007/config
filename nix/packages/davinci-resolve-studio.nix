{
  davinci-resolve-studio,
  perl,
  buildFHSEnv,
  bash,
  writeText,
  xkeyboard_config,
  ...
}:
# davinci-resolve-studio: 20.2.3: crack cause fuck h264/h265 license
davinci-resolve-studio.override {
  buildFHSEnv =
    oldFHSEnvArgs:
    (
      let
        davinciPatched = oldFHSEnvArgs.passthru.davinci.overrideAttrs (old: {
          postFixup = ''
            ${old.postFixup}
            #? for 19 version
            #? https://rutracker.org/forum/viewtopic.php?t=6088055&start=210
            # ${perl}/bin/perl -pi -e 's/\x74\x11\xe8\x21\x23\x00\x00/\xeb\x11\xe8\x21\x23\x00\x00/g' $out/bin/resolve
            #? for 20 version
            #? https://rutracker.org/forum/viewtopic.php?t=6088055&start=270
            ${perl}/bin/perl -pi -e 's/\x03\x00\x89\x45\xFC\x83\x7D\xFC\x00\x74\x11\x48\x8B\x45\xC8\x8B/\x03\x00\x89\x45\xFC\x83\x7D\xFC\x00\xEB\x11\x48\x8B\x45\xC8\x8B/' $out/bin/resolve
            ${perl}/bin/perl -pi -e 's/\x74\x11\x48\x8B\x45\xC8\x8B\x55\xFC\x89\x50\x58\xB8\x00\x00\x00/\xEB\x11\x48\x8B\x45\xC8\x8B\x55\xFC\x89\x50\x58\xB8\x00\x00\x00/' $out/bin/resolve
            ${perl}/bin/perl -pi -e 's/\x41\xb6\x01\x84\xc0\x0f\x84\xb0\x00\x00\x00\x48\x85\xdb\x74\x08\x45\x31\xf6\xe9\xa3\x00\x00\x00/\x41\xb6\x00\x84\xc0\x0f\x84\xb0\x00\x00\x00\x48\x85\xdb\x74\x08\x45\x31\xf6\xe9\xa3\x00\x00\x00/' $out/bin/resolve
            echo -e "LICENSE blackmagic davinciresolvestudio 999999 permanent uncounted\n  hostid=ANY issuer=CGP customer=CGP issued=28-dec-2023\n  akey=0000-0000-0000-0000 _ck=00 sig=\"00\"" > $out/.license/blackmagic.lic
          '';
        });
      in
      # This part overrides the wrapper, we need to replace all of the instances of ${davinci} with the patched version
      # Copies the parts from the official nixpkgs derivation that need overriding
      # https://github.com/NixOS/nixpkgs/blob/89c2b2330e733d6cdb5eae7b899326930c2c0648/pkgs/by-name/da/davinci-resolve/package.nix#L194
      buildFHSEnv (
        oldFHSEnvArgs
        // {
          targetPkgs =
            pkgs:
            builtins.filter (p: p.pname != "davinci-resolve-studio") (oldFHSEnvArgs.targetPkgs pkgs)
            ++ [ davinciPatched ];
          extraBwrapArgs = [
            #! ''--bind "$HOME"/.local/share/DaVinciResolve/license ${davinciPatched}/.license''
            ''--bind "$HOME"/.local/share/DaVinciResolve/Extras ${davinciPatched}/Extras''
          ];
          runScript = "${bash}/bin/bash ${writeText "davinci-wrapper" ''
            export QT_XKB_CONFIG_ROOT="${xkeyboard_config}/share/X11/xkb"
            export QT_PLUGIN_PATH="${davinciPatched}/libs/plugins:$QT_PLUGIN_PATH"
            export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/usr/lib:/usr/lib32:${davinciPatched}/libs
            ${davinciPatched}/bin/resolve
          ''}";
          extraInstallCommands = ''
            mkdir -p $out/share/applications $out/share/icons/hicolor/128x128/apps
            ln -s ${davinciPatched}/share/applications/*.desktop $out/share/applications/
            ln -s ${davinciPatched}/graphics/DV_Resolve.png $out/share/icons/hicolor/128x128/apps/davinci-resolve-studio.png
          '';
          passthru = {
            davinci = davinciPatched;
          };
        }
      )
    );
}
