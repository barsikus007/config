{ pkgs, ... }:
#? https://github.com/TNAZEP/HytaleLauncherFlake/blob/52bde7280b55863f9cc21cc1c063c7f657206fb6/flake.nix
let
  # runtime dependencies for the Tauri/WebKit-based launcher
  runtimeDeps = with pkgs; [
    glib
    gtk3
    webkitgtk_4_1
    gdk-pixbuf
    libsoup_3
    cairo
    pango
    harfbuzz
    atk
    openssl
    zlib
    icu
    libGL
  ];

  # FHS environment that downloads launcher at runtime
  hytale-launcher-fhs = pkgs.buildFHSEnv {
    name = "hytale-launcher";

    targetPkgs =
      pkgs:
      runtimeDeps
      ++ (with pkgs; [
        # additional runtime deps
        libx11
        libxcursor
        libxrandr
        libxi
        libxcb
        libxkbcommon
        mesa
        vulkan-loader
        alsa-lib
        pulseaudio
        dbus
        gsettings-desktop-schemas
        glib
        hicolor-icon-theme
        adwaita-icon-theme
        icu
        libGL
        # tools for downloading and patching
        curl
        unzip
        patchelf
      ]);

    profile = ''
      export GDK_BACKEND=x11
      export WEBKIT_DISABLE_COMPOSITING_MODE=1
      export XDG_DATA_DIRS="${pkgs.gsettings-desktop-schemas}/share/gsettings-schemas/${pkgs.gsettings-desktop-schemas.name}:${pkgs.gtk3}/share/gsettings-schemas/${pkgs.gtk3.name}:$XDG_DATA_DIRS"
    '';

    runScript = pkgs.writeShellScript "hytale-launcher-wrapper" ''
      set -e

      LAUNCHER_DIR="$HOME/.local/share/hytale-launcher"
      LAUNCHER_BIN="$LAUNCHER_DIR/hytale-launcher"
      DOWNLOAD_URL="https://launcher.hytale.com/builds/release/linux/amd64/hytale-launcher-latest.zip"

      # create launcher directory
      mkdir -p "$LAUNCHER_DIR"

      # download and set up launcher if it doesn't exist
      if [ ! -f "$LAUNCHER_BIN" ]; then
        echo "Downloading Hytale Launcher..."
        TEMP_DIR=$(mktemp -d)
        trap "rm -rf $TEMP_DIR" EXIT

        curl -L -o "$TEMP_DIR/launcher.zip" "$DOWNLOAD_URL"
        unzip -o "$TEMP_DIR/launcher.zip" -d "$TEMP_DIR"
        mv "$TEMP_DIR/hytale-launcher" "$LAUNCHER_BIN"
        chmod +x "$LAUNCHER_BIN"

        echo "Hytale Launcher installed successfully!"
      fi

      # run from mutable location (allows self-updates)
      cd "$LAUNCHER_DIR"
      exec "$LAUNCHER_BIN" "$@"
    '';

    meta = {
      description = "Hytale Game Launcher";
      homepage = "https://hytale.com";
      license = pkgs.lib.licenses.unfree;
      platforms = [ "x86_64-linux" ];
      mainProgram = "hytale-launcher";
    };
  };

  # desktop entry file
  desktopItem = pkgs.makeDesktopItem {
    name = "hytale-launcher";
    desktopName = "Hytale Launcher";
    comment = "Official Hytale Game Launcher";
    exec = "hytale-launcher";
    icon = "hytale-launcher";
    terminal = false;
    type = "Application";
    categories = [ "Game" ];
    keywords = [
      "hytale"
      "game"
      "launcher"
    ];
  };

  # fetch the Hytale icon
  hytaleIcon = pkgs.fetchurl {
    url = "https://hytale.com/images/favicon.png";
    hash = "sha256-eniMb/wct+vjtzXF2z8Z1XPBmwabjV8RCDyd8J1QLT0=";
  };

  # convert ico to png for better compatibility
  hytaleIconPng =
    pkgs.runCommand "hytale-launcher-icon"
      {
        nativeBuildInputs = [ pkgs.imagemagick ];
      }
      ''
        mkdir -p $out
        # extract the largest icon from the ico file and convert to png
        convert ${hytaleIcon} -thumbnail 256x256 -alpha on -background none -flatten $out/hytale-launcher.png
      '';
in
pkgs.symlinkJoin {
  name = "hytale-launcher";
  paths = [
    hytale-launcher-fhs
    desktopItem
  ];
  postBuild = ''
    mkdir -p $out/share/icons/hicolor/256x256/apps
    cp ${hytaleIconPng}/hytale-launcher.png $out/share/icons/hicolor/256x256/apps/hytale-launcher.png

    mkdir -p $out/share/pixmaps
    cp ${hytaleIconPng}/hytale-launcher.png $out/share/pixmaps/hytale-launcher.png
  '';
}
