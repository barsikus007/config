{
  lib,
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

  additionalVMSetupPs1 = writeTextFile {
    name = "AdditionalVMSetup.ps1";
    text = ''
      Invoke-WebRequest `
        -Uri https://looking-glass.io/artifact/bleeding/idd `
        -OutFile "C:\Windows\Temp\looking-glass-idd.zip"
      Expand-Archive -Path "C:\Windows\Temp\looking-glass-idd.zip" `
        -Destination "C:\Windows\Temp\looking-glass-idd" -Force
      Invoke-Expression "C:\Windows\Temp\looking-glass-idd\looking-glass-idd-setup.exe /S"

      Invoke-Expression "C:\Windows\Setup\Scripts\MAS_AIO.cmd /Z-Windows"
    '';
  };
  massgrave = builtins.fetchurl {
    name = "MAS_AIO.cmd";
    url = "https://dev.azure.com/massgrave/Microsoft-Activation-Scripts/_apis/git/repositories/Microsoft-Activation-Scripts/items?path=/MAS/All-In-One-Version-KL/MAS_AIO.cmd&download=true";
    sha256 = "sha256-Gu7PV5yWZZf+/ay5YWoOwBtDOKuTOr/8iGd2FgnmtsQ==";
  };

  authorizedKey = lib.strings.removeSuffix "\n" (
    builtins.readFile (
      builtins.fetchurl {
        url = "https://github.com/barsikus007.keys";
        sha256 = "sha256-Tnf/WxeYOikI9i5l4e0ABDk33I5z04BJFApJpUplNi0=";
      }
    )
  );

  scoopBuckets = [
    {
      name = "main";
      owner = "ScoopInstaller";
      repo = "Main";
      rev = "7439a1bd990a9d5e9fbdff9f045b6b58b2521724";
      hash = "sha256-oQ4zK4ftysXcsUxBwRYO8Tvq3U6U6nzowAJlJWZKgnE=";
    }
    {
      name = "extras";
      owner = "ScoopInstaller";
      repo = "Extras";
      rev = "32d754589df86c576bf218b796afe0e6de60a8c6";
      hash = "sha256-OdJEAce91fLgwCSPidYDaje4qcgAcUaprfqHOE5CSdE=";
    }
    # postFetch = ''
    #   mkdir -p $out/.git/refs/{heads,remotes}
    #   echo ${rev} > $out/.git/refs/heads/master
    #   echo "ref: refs/remotes/origin/master" >
    # '';
  ];
  scoopPackages = [
    "main/aria2"
    "main/7zip"
  ];

  # TODO: & ([ScriptBlock]::Create((irm https://get.activated.win))) /Z-WindowsESUOffice
  # TODO: https://www.reddit.com/r/techsupport/comments/ehgbmu/windows_10_oemcustomizations/
  # TODO: scoopPackages: scoop/cache
  isoDir = runCommand "iso-content" { } ''
    mkdir -p $out
    cp ${unattend}               $out/autounattend.xml

    mkdir -p $out/\$OEM\$/\$\$/Setup/Scripts
    cp ${additionalVMSetupPs1}   $out/\$OEM\$/\$\$/Setup/Scripts/AdditionalVMSetup.ps1
    cp ${massgrave}              $out/\$OEM\$/\$\$/Setup/Scripts/MAS_AIO.cmd

    mkdir -p $out/\$OEM\$/\$1/Users/Default/.ssh
    echo "${authorizedKey}" >    $out/\$OEM\$/\$1/Users/Default/.ssh/authorized_keys

    ${lib.strings.concatStringsSep "\n" (
      lib.lists.forEach scoopBuckets (bucket: ''
        BUCKET_DIR=$out/\$OEM\$/\$1/Users/Default/scoop/buckets/${bucket.name}
        mkdir -p $BUCKET_DIR/.git
        cp -a ${
          fetchFromGitHub {
            inherit (bucket)
              owner
              repo
              rev
              hash
              ;
          }
        }/. $BUCKET_DIR
        echo '[remote "origin"]
            url = https://github.com/ScoopInstaller/${bucket.repo}
            fetch = +refs/heads/*:refs/remotes/origin/*
        [branch "master"]
            remote = origin
            merge = refs/heads/master
        ' > $BUCKET_DIR/.git/config
      '')
    )}
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
