# ---------- Adobe Photoshop 2021 ----------
# `src` must reference a zip file containing the directories:
#   - `photoshop`: The installed Photoshop directory
#     - Typically found at `C:\Program Files\Adobe\Adobe Photoshop 2021`
#   - `common`: The (x86) Adobe common files directory
#     - Typically found at `C:\Program Files (x86)\Common Files\Adobe`
#     - Note that this differs from the common files under `Program Files` (not x86!)

{
  lib,
  mkWindowsAppNoCC,
  wine,
  fetchurl,
  src,
  uiScale ? null,
  version ? "2021",
  photoshopDir ? "Adobe Photoshop 2021",
  makeDesktopItem,
  makeDesktopIcon, # This comes with erosanix. It's a handy way to generate desktop icons.
  copyDesktopItems,
  copyDesktopIcons, # This comes with erosanix. It's a handy way to generate desktop icons.
  unzip,
  ...
}:
# https://github.com/NatKarmios/nix-config/blob/6a958617829d6f91e20905a256c02a37a5544aca/pkgs/photoshop.nix
# https://rutracker.org/forum/viewtopic.php?t=5970995
let
  programDir = "$WINEPREFIX/drive_c/Program Files/Adobe";
  commonDir = "$WINEPREFIX/drive_c/Program Files (x86)/Common Files";
in
mkWindowsAppNoCC rec {
  inherit src wine version;

  pname = "photoshop";
  dontUnpack = true;
  wineArch = "win64";
  enableMonoBootPrompt = false;

  fileMap = {
    "$XDG_CONFIG_HOME/${pname}/roaming" = "drive_c/users/$USER/AppData/Roaming/Adobe";
    "$XDG_CONFIG_HOME/${pname}/local" = "drive_c/users/$USER/AppData/Local/Adobe";
    "$XDG_CONFIG_HOME/${pname}/locallow" = "drive_c/users/$USER/AppData/LocalLow/Adobe";
  };

  enableVulkan = true;
  graphicsDriver = "auto";
  nativeBuildInputs = [
    copyDesktopItems
    copyDesktopIcons
  ];

  winAppInstall =
    let
      setScale =
        if uiScale == null then
          ""
        else
          ''
            scaleRegFile=$(mktemp)
            (
              echo "REGEDIT4"
              echo
              echo "[HKEY_LOCAL_MACHINE\System\CurrentControlSet\Hardware Profiles\Current\Software\Fonts]"
              echo "\"LogPixels\"=dword:$(printf '%08x' "${uiScale}")"
            ) > $scaleRegFile
            regedit $scaleRegFile
          '';
    in
    ''
      winetricks --unattended corefonts win10 vkd3d dxvk2030 msxml3 msxml6 gdiplus \
        vcrun2003 vcrun2005 vcrun2010 vcrun2012 vcrun2013 vcrun2022

      mkdir -p "${programDir}"
      mkdir -p "${commonDir}"
      tmpdir=$(mktemp -d)
      ${lib.getExe unzip} ${src} -d "$tmpdir"
      mv "$tmpdir/photoshop" "${programDir}/${photoshopDir}"
      mv "$tmpdir/common" "${commonDir}/Adobe"

      ${setScale}
    '';

  winAppRun = ''
    wine "${programDir}/${photoshopDir}/photoshop.exe" "$ARGS"
  '';

  # This code will run after winAppRun, but only for the first instance.
  # Therefore, if the app was already running, winAppPostRun will not execute.
  # In other words, winAppPostRun is only executed if winAppPreRun is executed.
  # Use this to do any cleanup after the app has terminated
  winAppPostRun = "";

  # This is a normal mkDerivation installPhase, with some caveats.
  # The launcher script will be installed at $out/bin/.launcher
  # DO NOT DELETE OR RENAME the launcher. Instead, link to it as shown.
  installPhase = ''
    runHook preInstall

    ln -s $out/bin/.launcher $out/bin/${pname}

    runHook postInstall
  '';

  desktopItems = [
    (makeDesktopItem {
      mimeTypes = [
        "image/apng"
        "image/avif"
        "image/bmp"
        "image/gif"
        "image/jpeg"
        "image/png"
        "image/svg+xml"
        "image/tiff"
        "image/webp"
      ];

      name = pname;
      exec = pname;
      icon = pname;
      desktopName = "Adobe Photoshop";
      genericName = "Image Editor";
      categories = [
        "Graphics"
        "2DGraphics"
        "RasterGraphics"
        "Photography"
      ];
    })
  ];

  desktopIcon = makeDesktopIcon {
    name = "photoshop";

    src = fetchurl {
      url = "https://upload.wikimedia.org/wikipedia/commons/thumb/a/af/Adobe_Photoshop_CC_icon.svg/512px-Adobe_Photoshop_CC_icon.svg.png";
      sha256 = "sha256-bQeCaZz64LfFFS5w1o5DcaTlJYH9vkMTw9gutpeF43k=";
    };
  };

  meta = with lib; {
    platforms = [ "x86_64-linux" ];
  };
}
