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
  perlExec = lib.concatMapStrings (
    patch: "${lib.getExe perl} -0777 -pi -e '${patch}' $out/bin/resolve\n"
  ) perlPatches;
in
davinci-resolve-studio.override (previous: {
  buildFHSEnv =
    oldFHSEnvArgs:
    previous.buildFHSEnv (
      oldFHSEnvArgs
      // {
        extraBwrapArgs = builtins.filter (
          n: !(lib.strings.hasInfix "license" n)
        ) oldFHSEnvArgs.extraBwrapArgs;
      }
    );
  stdenv = previous.stdenv // {
    mkDerivation =
      drvArgs:
      previous.stdenv.mkDerivation (
        if builtins.isAttrs drvArgs && (drvArgs.pname or "") == "davinci-resolve-studio" then
          drvArgs
          // {
            preFixup = ''
              ${drvArgs.preFixup or ""}
              rm --force $out/libs/lib{glib,gobject,gio,gmodule,gthread}-2.0.so*
            '';
            postFixup = ''
              ${drvArgs.postFixup or ""}
              ${perlExec}
              printf 'LICENSE blackmagic davinciresolvestudio 999999 permanent uncounted\nhostid=ANY issuer=CGP customer=CGP issued=28-dec-2023\nakey=0000-0000-0000-0000 _ck=00 sig="00"\n' > $out/.license/blackmagic.lic
            '';
          }
        else
          drvArgs
      );
  };
})
