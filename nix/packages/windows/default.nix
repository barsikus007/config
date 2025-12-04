{
  lib,
  callPackage,
  runCommand,
  xorriso,
}:
#? alternatives:
# https://git.m-labs.hk/M-Labs/wfvm
# https://github.com/MatthewCroughan/NixThePlanet
# https://git.stupid.fish/teidesu/nixfiles/src/branch/master/lib/windows
let
  unattend = callPackage ./unattend.nix { };

  additionalVMSetupPs1 = ./AdditionalVMSetup.ps1;
  massgrave = builtins.fetchurl {
    name = "MAS_AIO.cmd";
    url = "https://dev.azure.com/massgrave/Microsoft-Activation-Scripts/_apis/git/repositories/Microsoft-Activation-Scripts/items?path=/MAS/All-In-One-Version-KL/MAS_AIO.cmd&download=true";
    sha256 = "sha256-Gu7PV5yWZZf+/ay5YWoOwBtDOKuTOr/8iGd2FgnmtsQ==";
  };

  openSshServerPackage = builtins.fetchurl {
    url = "https://github.com/PowerShell/Win32-OpenSSH/releases/download/10.0.0.0p2-Preview/OpenSSH-Win64.zip";
    sha256 = "sha256-I/UPNFjExdCxIhfGpd394BNyEKMPqHDpiymCf3tDq6U=";
  };
  authorizedKeys = [
    (lib.strings.removeSuffix "\n" (
      builtins.readFile (
        builtins.fetchurl {
          url = "https://github.com/barsikus007.keys";
          sha256 = "sha256-Tnf/WxeYOikI9i5l4e0ABDk33I5z04BJFApJpUplNi0=";
        }
      )
    ))
  ];

  # scoop = callPackage ./scoop.nix { };
  # mkdir -p $out/\$OEM\$/\$1/Users/Default
  # cp -r ${scoop} $out/\$OEM\$/\$1/Users/Default/scoop

  # TODO: & ([ScriptBlock]::Create((irm https://get.activated.win))) /Z-Windows
  # TODO: https://www.reddit.com/r/techsupport/comments/ehgbmu/windows_10_oemcustomizations/
  isoDir = runCommand "iso-content" { } ''
    mkdir -p $out
    cp ${unattend} $out/autounattend.xml

    mkdir -p $out/\$OEM\$/\$\$/Setup/Scripts
    cp ${additionalVMSetupPs1} $out/\$OEM\$/\$\$/Setup/Scripts/AdditionalVMSetup.ps1

    mkdir -p $out/\$OEM\$/\$\$/Temp
    cp ${massgrave} $out/\$OEM\$/\$\$/Setup/Scripts/MAS_AIO.cmd
    cp ${openSshServerPackage} $out/\$OEM\$/\$\$/Temp/OpenSSH-Win64.zip

    mkdir -p $out/\$OEM\$/\$1/ProgramData/ssh
    echo "${lib.strings.concatStringsSep "\n" authorizedKeys}" >  $out/\$OEM\$/\$1/ProgramData/ssh/administrators_authorized_keys
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
