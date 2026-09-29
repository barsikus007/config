{
  lib,
  fetchurl,
  _7zz,
  callPackage,
  runCommand,
  virtio-win,
  xorriso,
  withNvidia ? false,
  withTweaks ? false,
  withUpdates ? false,
}:
#? alternatives:
# https://git.m-labs.hk/M-Labs/wfvm
# https://github.com/MatthewCroughan/NixThePlanet
# https://git.stupid.fish/teidesu/nixfiles/src/branch/master/lib/windows
let
  unattend = callPackage ./unattend.nix { };

  additionalVMSetupPs1 = ./AdditionalVMSetup.ps1;
  massgrave = fetchurl {
    name = "MAS_AIO.cmd";
    url = "https://dev.azure.com/massgrave/Microsoft-Activation-Scripts/_apis/git/repositories/Microsoft-Activation-Scripts/items?path=/MAS/All-In-One-Version-KL/MAS_AIO.cmd&download=true";
    hash = "sha256-hQ+XlmX7k5mayuk/R5DB/47SBBUyBgt5ZqEhwtKaC/o=";
  };

  openSshServerPackage = fetchurl {
    url = "https://github.com/PowerShell/Win32-OpenSSH/releases/download/10.0.0.0p2-Preview/OpenSSH-Win64.zip";
    hash = "sha256-I/UPNFjExdCxIhfGpd394BNyEKMPqHDpiymCf3tDq6U=";
  };
  authorizedKeys = fetchurl {
    url = "https://github.com/barsikus007.keys";
    hash = "sha256-Tnf/WxeYOikI9i5l4e0ABDk33I5z04BJFApJpUplNi0=";
  };

  #? Looking Glass IDD driver pinned to host client commit
  lookingGlassIdd = fetchurl {
    name = "looking-glass-idd.zip";
    url = "https://looking-glass.io/artifact/B7-826-236efcb1/idd";
    hash = "sha256-NNqm3bQDwfUD+yrOlDYBWYGP2heV/Fwr5c7B9DkdXVc=";
  };

  #? Nvidia Game Ready Driver
  nvidiaInstaller = fetchurl {
    url = "https://us.download.nvidia.com/Windows/617.14/617.14-notebook-win10-win11-64bit-international-dch-whql.exe";
    hash = "sha256-Y9PaXtUlR78/2GIEu56hRVlHsk4qolGfNZEm+abv4T8=";
  };

  #? fetch with: python3 ./get-latest-update.py
  cumulativeUpdate = fetchurl {
    name = "windows10.0-kb5129236-x64.msu";
    url = "https://catalog.s.download.windowsupdate.com/d/msdownload/update/software/updt/2026/09/windows10.0-kb5129236-x64_4413bfb0ab8a665cd0244ed67ec361170bb12ecb.msu";
    hash = "sha1-RBO/sKuKZlzQJE7WfsNhFwuxLss=";
  };

  cumulativeUpdateDotnet = fetchurl {
    name = "windows10.0-kb5126046-x64-ndp48.msu";
    url = "https://catalog.s.download.windowsupdate.com/c/msdownload/update/software/secu/2026/08/windows10.0-kb5126046-x64-ndp48_28db9902cf368f5a674c016e0bd3f1d63ab8578d.msu";
    hash = "sha1-KNuZAs82j1pnTAFuC9Px1jq4V40=";
  };

  # scoop = callPackage ./scoop.nix { };
  # mkdir --parents $out/\$OEM\$/\$1/Users/Default
  # cp --recursive ${scoop} $out/\$OEM\$/\$1/Users/Default/scoop

  # TODO: & ([ScriptBlock]::Create((irm https://get.activated.win))) /Z-Windows
  # TODO: https://www.reddit.com/r/techsupport/comments/ehgbmu/windows_10_oemcustomizations/
  isoDir = runCommand "iso-content" { } ''
    mkdir --parents $out

    cp ${unattend} $out/autounattend.xml

    mkdir --parents $out/\$OEM\$/\$\$/Setup/Scripts
    cp ${additionalVMSetupPs1} $out/\$OEM\$/\$\$/Setup/Scripts/AdditionalVMSetup.ps1

    cp --recursive ${virtio-win}/* $out/

    mkdir --parents $out/\$WinPEDriver\$/viostor
    cp ${virtio-win}/viostor/w10/amd64/* $out/\$WinPEDriver\$/viostor/

    chmod --recursive +w $out/

    mkdir --parents $out/\$OEM\$/\$\$/Temp
    cp ${massgrave} $out/\$OEM\$/\$\$/Setup/Scripts/MAS_AIO.cmd
    cp ${openSshServerPackage} $out/\$OEM\$/\$\$/Temp/OpenSSH-Win64.zip
    cp ${lookingGlassIdd} $out/\$OEM\$/\$\$/Temp/looking-glass-idd.zip

    mkdir --parents $out/\$OEM\$/\$1/ProgramData/ssh
    cp ${authorizedKeys} $out/\$OEM\$/\$1/ProgramData/ssh/administrators_authorized_keys

    ${lib.optionalString withNvidia ''
      mkdir --parents $out/drivers/nvidia
      ${_7zz}/bin/7zz x ${nvidiaInstaller} Display.Driver NvApp NVI2 EULA.txt ListDevices.txt setup.cfg setup.exe -o$out/drivers/nvidia
    ''}

    ${lib.optionalString withUpdates ''
      mkdir --parents $out/updates
      cp ${cumulativeUpdate} $out/updates/01-latest-lcu.msu
      cp ${cumulativeUpdateDotnet} $out/updates/02-latest-dotnet.msu
    ''}

    ${lib.optionalString withTweaks ''
      mkdir --parents $out/scripts
      cat > $out/scripts/01-tweaks.ps1 << 'EOF'
      Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser -Force
      irm https://raw.githubusercontent.com/barsikus007/config/refs/heads/master/windows/installOnWin10LTSC.ps1 | iex
      irm https://raw.githubusercontent.com/barsikus007/config/refs/heads/master/windows/99Tweaks.ps1 | iex
      EOF
    ''}
  '';
in
runCommand "unattend-win10-iot-ltsc-vrt.iso" { nativeBuildInputs = [ xorriso ]; } ''
  xorriso -as mkisofs \
    -V UNATTEND \
    -rJ -o $out \
    ${isoDir}
''
