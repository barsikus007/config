{ pkgs, ... }:
# studio crack cause fuck h264/h265 license
# davinci-resolve-studio: 19.1
# thx https://github.com/WJC5197/nixos-config/blob/ac2fdac2026e67cf1c744b67a224b63493bcc886/pkgs/davinci-resolve-custom/default.nix
# https://rutracker.org/forum/viewtopic.php?t=6088055&start=210
{
  nixpkgs.overlays = [
    (self: super: {
      davinci-resolve-studio = super.davinci-resolve-studio.override (old: {
        buildFHSEnv =
          fhs:
          (
            let
              # This is the actual DaVinci binary, we can run perl here
              davinci = fhs.passthru.davinci.overrideAttrs (old: {
                postFixup = ''
                  ${old.postFixup}
                  ${super.perl}/bin/perl -pi -e 's/\x74\x11\xe8\x21\x23\x00\x00/\xeb\x11\xe8\x21\x23\x00\x00/g' $out/bin/resolve
                '';
              });
            in
            # This part overrides the wrapper, we need to replace all of the instances of ${davinci} with the patched version
            # Copies the parts from the official nixpkgs derivation that need overriding
            # https://github.com/NixOS/nixpkgs/blob/d82502b7773487d325a541ce84deb166cea3748a/pkgs/by-name/da/davinci-resolve/package.nix
            super.buildFHSEnv (
              fhs
              // {
                targetPkgs =
                  pkgs: with pkgs; [
                    alsa-lib
                    aprutil
                    bzip2
                    davinci # ! override davinci to reduce duplication
                    dbus
                    expat
                    fontconfig
                    freetype
                    glib
                    libGL
                    libGLU
                    libarchive
                    libcap
                    librsvg
                    libtool
                    libuuid
                    libxcrypt # provides libcrypt.so.1
                    libxkbcommon
                    nspr
                    ocl-icd
                    opencl-headers
                    python3
                    python3.pkgs.numpy
                    udev
                    xdg-utils # xdg-open needed to open URLs
                    xorg.libICE
                    xorg.libSM
                    xorg.libX11
                    xorg.libXcomposite
                    xorg.libXcursor
                    xorg.libXdamage
                    xorg.libXext
                    xorg.libXfixes
                    xorg.libXi
                    xorg.libXinerama
                    xorg.libXrandr
                    xorg.libXrender
                    xorg.libXt
                    xorg.libXtst
                    xorg.libXxf86vm
                    xorg.libxcb
                    xorg.xcbutil
                    xorg.xcbutilimage
                    xorg.xcbutilkeysyms
                    xorg.xcbutilrenderutil
                    xorg.xcbutilwm
                    xorg.xkeyboardconfig
                    zlib
                  ];
                extraBwrapArgs = [
                  "--bind \"$HOME\"/.local/share/DaVinciResolve/license ${davinci}/.license"
                  #! Added from https://discourse.nixos.org/t/davinci-resolve-studio-install-issues/37699/44
                  "--bind /run/opengl-driver/etc/OpenCL /etc/OpenCL"
                ];
                runScript = "${pkgs.bash}/bin/bash ${pkgs.writeText "davinci-wrapper" ''
                  export QT_XKB_CONFIG_ROOT="${pkgs.xkeyboard_config}/share/X11/xkb"
                  export QT_PLUGIN_PATH="${davinci}/libs/plugins:$QT_PLUGIN_PATH"
                  export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/usr/lib:/usr/lib32:${davinci}/libs
                  #! Having this set to wayland causes issues
                  unset QT_QPA_PLATFORM
                  ${davinci}/bin/resolve
                ''}";
                extraInstallCommands = ''
                  mkdir -p $out/share/applications $out/share/icons/hicolor/128x128/apps
                  ln -s ${davinci}/share/applications/*.desktop $out/share/applications/
                  ln -s ${davinci}/graphics/DV_Resolve.png $out/share/icons/hicolor/128x128/apps/davinci-resolve-studio.png
                '';
                passthru = { inherit davinci; };
              }
            )
          );
      });
    })
  ];

  environment.systemPackages = with pkgs; [
    davinci-resolve-studio
  ];
}
