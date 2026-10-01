{
  lib,
  fetchurl,
  _7zz,
  callPackage,
  runCommand,
  virtio-win,
  writeText,
  xorriso,
  firefoxPolicies ? null,
  firefoxProfileFiles ? null,
  withNvidia ? false,
  withUpdates ? false,
  withTweaks ? false,
  withAdditionalTweaks ? false,
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

  scoop = callPackage ./scoop.nix { };

  firefoxPoliciesJson =
    if firefoxPolicies != null then
      writeText "policies.json" (builtins.toJSON { policies = firefoxPolicies; })
    else
      null;

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

    mkdir --parents $out/scoop-hydrated
    cp ${scoop}/scoop-buckets.zip $out/scoop-hydrated/scoop-buckets.zip
    cp --recursive ${scoop}/cache $out/scoop-hydrated/cache

    ${lib.optionalString (firefoxPoliciesJson != null) ''
      mkdir --parents $out/firefox/distribution
      cp ${firefoxPoliciesJson} $out/firefox/distribution/policies.json
    ''}

    ${lib.optionalString (firefoxProfileFiles != null) ''
      mkdir --parents $out/firefox/profile/chrome
      cp ${firefoxProfileFiles.userJs} $out/firefox/profile/user.js
      awk '{
        if ($0 ~ /^@import "\/nix\/store\//) {
          match($0, /"([^"]+)"/, arr)
          while ((getline line < arr[1]) > 0) print line
          close(arr[1])
        } else {
          print $0
        }
      }' ${firefoxProfileFiles.userChrome} > $out/firefox/profile/chrome/userChrome.css
      cp ${firefoxProfileFiles.search} $out/firefox/profile/search.json.mozlz4
    ''}

    ${lib.optionalString withNvidia ''
      mkdir --parents $out/drivers/nvidia
      ${_7zz}/bin/7zz x ${nvidiaInstaller} Display.Driver PPC NvApp NVI2 EULA.txt ListDevices.txt setup.cfg setup.exe -o$out/drivers/nvidia
    ''}

    ${lib.optionalString withUpdates ''
      mkdir --parents $out/updates
      cp ${cumulativeUpdate} $out/updates/01-latest-lcu.msu
      cp ${cumulativeUpdateDotnet} $out/updates/02-latest-dotnet.msu
    ''}

    ${lib.optionalString withTweaks ''
      mkdir --parents $out/scripts
      cp --recursive ${./scripts}/* $out/scripts/
      chmod --recursive +w $out/scripts/
      cat > $out/scripts/00AutoInstallTweaks.ps1 << 'EOF'
      Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser -Force -ErrorAction SilentlyContinue
      $scriptDir = $PSScriptRoot
      if (-not $scriptDir) {
          foreach ($letter in 'ABCDEFGHIJKLMNOPQRSTUVWXYZ'.ToCharArray()) {
              if (Test-Path "''${letter}:\scripts\installOnWin10LTSC.ps1") {
                  $scriptDir = "''${letter}:\scripts"
                  break
              }
          }
      }
      if ($scriptDir -and (Test-Path "$scriptDir\installOnWin10LTSC.ps1")) {
          & "$scriptDir\installOnWin10LTSC.ps1"
      }
      ${lib.optionalString withAdditionalTweaks ''
        if ($scriptDir -and (Test-Path "$scriptDir\99Tweaks.ps1")) {
            & "$scriptDir\99Tweaks.ps1"
        }
      ''}
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
