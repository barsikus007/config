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
              ${lib.getExe perl} -0777 -pi -e 's/\x03\x00\x89\x45\xFC\x83\x7D\xFC\x00\x74\x11\x48\x8B\x45\xC8\x8B/\x03\x00\x89\x45\xFC\x83\x7D\xFC\x00\xEB\x11\x48\x8B\x45\xC8\x8B/' $out/bin/resolve
              ${lib.getExe perl} -0777 -pi -e 's/\x74\x11\x48\x8B\x45\xC8\x8B\x55\xFC\x89\x50\x58\xB8\x00\x00\x00/\xEB\x11\x48\x8B\x45\xC8\x8B\x55\xFC\x89\x50\x58\xB8\x00\x00\x00/' $out/bin/resolve
              ${lib.getExe perl} -0777 -pi -e 's/\x74(.\xBF\x16\x00\x00\x00\xBE.\x01\x00\x00\xE8..\x05)/\x75$1/' $out/bin/resolve
              printf 'LICENSE blackmagic davinciresolvestudio 999999 permanent uncounted\nhostid=ANY issuer=CGP customer=CGP issued=28-dec-2023\nakey=0000-0000-0000-0000 _ck=00 sig="00"\n' > $out/.license/blackmagic.lic
            '';
          }
        else
          drvArgs
      );
  };
})
