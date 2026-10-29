{
  lib,
  davinci-resolve-studio,
  perl,
  ...
}:
#? for 19 version only the first perl line is needed
#? https://rutracker.org/forum/viewtopic.php?t=6088055&start=210
#? for 20 version
#? https://rutracker.org/forum/viewtopic.php?t=6088055&start=270
#? for 21 version
#? https://rutracker.org/forum/viewtopic.php?p=89210992#89210992
#? for 21.0.4 version
#? https://rutracker.org/forum/viewtopic.php?p=89460659#89460659
let
  perlPatches = [
    ''s/\xBE\x05\x00\x00\x00\xE8\x0B\x8A\x01\x00\x84\xC0\x0F\x84\xCA\x00\x00\x00/\xBE\x05\x00\x00\x00\xE8\x0B\x8A\x01\x00\x84\xC0\x90\x90\x90\x90\x90\x90/''
    ''s/\xB3\x01\xE8\x64\x92\x98\x03\x84\xC0\x0F\x85\xC9\x00\x00\x00/\xB3\x01\xE8\x64\x92\x98\x03\x84\xC0\x90\xE9\xC9\x00\x00\x00/''
    ''s/\x74(.\xBF\x16\x00\x00\x00\xBE.\x01\x00\x00(?:\x89\xC2\x89\xC3)?\xE8)/\x75$1/g''
  ];

  perlExec = lib.concatMapStringsSep "\n" (
    patch: ''${lib.getExe perl} -0777 -pi -e ${lib.escapeShellArg patch} "$out/bin/resolve"''
  ) perlPatches;

  patchFhsArgs =
    args:
    args
    // {
      extraBwrapArgs = builtins.filter (arg: !(lib.hasInfix "license" arg)) args.extraBwrapArgs;
    };

  patchResolveArgs =
    args:
    if builtins.isAttrs args && (args.pname or "") == "davinci-resolve-studio" then
      args
      // {
        preFixup = ''
          ${args.preFixup or ""}
          rm --force "$out"/libs/lib{glib,gobject,gio,gmodule,gthread}-2.0.so*
        '';

        postFixup = ''
          ${args.postFixup or ""}
          ${perlExec}

          printf '%s\n' \
            'LICENSE blackmagic davinciresolvestudio 999999 permanent uncounted' \
            'hostid=ANY issuer=CGP customer=CGP issued=28-dec-2023' \
            'akey=0000-0000-0000-0000 _ck=00 sig="00"' \
            > "$out/.license/blackmagic.lic"
        '';
      }
    else
      args;
in
davinci-resolve-studio.override (
  lib.updateManyAttrsByPath [
    {
      path = [ "buildFHSEnv" ];
      update = build: args: build (patchFhsArgs args);
    }
    {
      path = [
        "stdenv"
        "mkDerivation"
      ];
      update = build: args: build (patchResolveArgs args);
    }
  ]
)
