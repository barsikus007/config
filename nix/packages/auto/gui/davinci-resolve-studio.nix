{
  lib,
  davinci-resolve-studio,
  perl,
  replaceDependencies,
  ...
}:
let
  davinci-resolve-studio-licenseless = davinci-resolve-studio.override (previous: {
    buildFHSEnv =
      oldFHSEnvArgs:
      (previous.buildFHSEnv (
        oldFHSEnvArgs
        // {
          extraBwrapArgs = builtins.filter (
            n: !(lib.strings.hasInfix "license" n)
          ) oldFHSEnvArgs.extraBwrapArgs;
        }
      ));
  });
in
let
  davinci = davinci-resolve-studio-licenseless.passthru.davinci;
  davinciPatched = davinci.overrideAttrs (
    #? for 19 version
    #? https://rutracker.org/forum/viewtopic.php?t=6088055&start=210
    # ${lib.getExe perl} -pi -e 's/\x74\x11\xe8\x21\x23\x00\x00/\xeb\x11\xe8\x21\x23\x00\x00/g' $out/bin/resolve
    #? for 20 version
    #? https://rutracker.org/forum/viewtopic.php?t=6088055&start=270
    finalAttrs: previousAttrs: {
      postFixup = ''
        ${previousAttrs.postFixup}
        ${lib.getExe perl} -pi -e 's/\x03\x00\x89\x45\xFC\x83\x7D\xFC\x00\x74\x11\x48\x8B\x45\xC8\x8B/\x03\x00\x89\x45\xFC\x83\x7D\xFC\x00\xEB\x11\x48\x8B\x45\xC8\x8B/' $out/bin/resolve
        ${lib.getExe perl} -pi -e 's/\x74\x11\x48\x8B\x45\xC8\x8B\x55\xFC\x89\x50\x58\xB8\x00\x00\x00/\xEB\x11\x48\x8B\x45\xC8\x8B\x55\xFC\x89\x50\x58\xB8\x00\x00\x00/' $out/bin/resolve
        ${lib.getExe perl} -pi -e 's/\x41\xb6\x01\x84\xc0\x0f\x84\xb0\x00\x00\x00\x48\x85\xdb\x74\x08\x45\x31\xf6\xe9\xa3\x00\x00\x00/\x41\xb6\x00\x84\xc0\x0f\x84\xb0\x00\x00\x00\x48\x85\xdb\x74\x08\x45\x31\xf6\xe9\xa3\x00\x00\x00/' $out/bin/resolve
        echo -e "LICENSE blackmagic davinciresolvestudio 999999 permanent uncounted\nhostid=ANY issuer=CGP customer=CGP issued=28-dec-2023\nakey=0000-0000-0000-0000 _ck=00 sig=\"00\"" > $out/.license/blackmagic.lic
      '';
    }
  );
in
replaceDependencies {
  drv = davinci-resolve-studio-licenseless;
  replacements = [
    {
      oldDependency = davinci;
      newDependency = davinciPatched;
    }
  ];
}
