{
  callPackage,
  fetchFromGitHub,
  writeTextFile,
  runCommand,
  xorriso,
}:
#? alternatives:
# https://git.m-labs.hk/M-Labs/wfvm
# https://github.com/MatthewCroughan/NixThePlanet
# https://git.stupid.fish/teidesu/nixfiles/src/branch/master/lib/windows
let
  unattend = callPackage ./unattend.nix { };
  scoopBucketMain = fetchFromGitHub {
    owner = "ScoopInstaller";
    repo = "Main";
    rev = "7439a1bd990a9d5e9fbdff9f045b6b58b2521724";
    hash = "sha256-atLFGU+PLlGu5ydgOq8momsS9d6DNJXsftuyr7Aadz8=";
    deepClone = true;
  };
  scoopBucketExtras = fetchFromGitHub {
    owner = "ScoopInstaller";
    repo = "Extras";
    rev = "fd88db6be9d32263da516c77d7765e2517d6eadb";
    hash = "sha256-AThGnK1GgZmQHnfBVOJm8ow1/QIf3WV/JOsYPaorEv4=";
    deepClone = true;
  };
  installPs1 = writeTextFile {
    name = "Install.ps1";
    text = ''
      Invoke-WebRequest `
        -Uri https://www.spice-space.org/download/windows/spice-guest-tools/spice-guest-tools-latest.exe `
        -OutFile "C:\Windows\Temp\spice-guest-tools-latest.exe"
      Invoke-Expression "C:\Windows\Temp\spice-guest-tools-latest.exe /S"

      Invoke-WebRequest `
        -Uri https://looking-glass.io/artifact/bleeding/idd `
        -OutFile "C:\Windows\Temp\looking-glass-idd.zip"
      Expand-Archive -Path "C:\Windows\Temp\looking-glass-idd.zip" `
        -Destination "C:\Windows\Temp\looking-glass-idd" -Force
      Invoke-Expression "C:\Windows\Temp\looking-glass-idd\looking-glass-idd-setup.exe /S"
    '';
  };

  isoDir = runCommand "iso-content" { } ''
    mkdir -p $out
    cp ${unattend}               $out/autounattend.xml

    mkdir -p $out/\$OEM\$/\$1/Users/Default/scoop/buckets/{main,extras}
    cp -a ${scoopBucketMain}/.   $out/\$OEM\$/\$1/Users/Default/scoop/buckets/main
    cp -a ${scoopBucketExtras}/. $out/\$OEM\$/\$1/Users/Default/scoop/buckets/extras

    mkdir -p $out/\$OEM\$/\$\$/Setup/Scripts
    cp ${installPs1}             $out/\$OEM\$/\$\$/Setup/Scripts/Install.ps1
  '';
in
runCommand "unattend-win10-iot-ltsc-vrt.iso"
  {
    nativeBuildInputs = [ xorriso ];
  }
  ''
    xorriso -as mkisofs \
      -V UNATTEND \
      -rJ -o $out \
      ${isoDir}
  ''
