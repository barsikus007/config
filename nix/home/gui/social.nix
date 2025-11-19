{
  lib,
  pkgs,
  inputs,
  ...
}:
# Да.
{
  xdg.mimeApps = {
    defaultApplications = {
      "x-scheme-handler/discord" = [
        "vesktop.desktop"
        "discord.desktop"
      ];
    }
    // lib.genAttrs [
      "x-scheme-handler/tg"
      "x-scheme-handler/tonsite"
    ] (key: "com.ayugram.desktop.desktop");
  };
  imports = [
    inputs.nixcord.homeModules.nixcord
  ];
  programs.nixcord = {
    enable = true;
    discord = {
      # enable = false;
      # branch = "canary";
      autoscroll.enable = true;
      openASAR.enable = false;
    };
    vesktop = {
      enable = true;
      autoscroll.enable = true;
      settings = {
        customTitleBar = true;
        # alo set default settings
        arRPC = true;
        splashColor = "rgb(239, 239, 240)";
        splashBackground = "rgb(32, 32, 36)";
      };
    };
    dorion = {
      # enable = true;
      #! parameters untested, waiting for dorion to have voice chat support

      # blur = "acrylic";
      # cacheCss = true;

      # blurCss = true;
      updateNotify = false;
      # useNativeTitlebar = true;
      # disableHardwareAccel = true;
    };
    config = {
      disableMinSize = true;
      plugins = {
        #? restrictions
        fakeNitro.enable = true;
        showHiddenChannels.enable = true;
        showConnections.enable = true;
        silentTyping = {
          enable = true;
          showIcon = true;
        };
        forceOwnerCrown.enable = true;
        platformIndicators.enable = true;
        permissionFreeWill.enable = true;
        noMosaic.enable = true;
        voiceMessages.enable = true;
        biggerStreamPreview.enable = true;
        greetStickerPicker.enable = true;
        volumeBooster.enable = true;

        #? additions
        shikiCodeblocks.enable = true;
        reverseImageSearch.enable = true;
        # messageLogger.enable = true;

        #? tweaks
        noF1.enable = true;
        betterGifAltText.enable = true;
        alwaysTrust.enable = true;
        quickReply.enable = true;
        previewMessage.enable = true;
        pictureInPicture.enable = true;
        copyUserURLs.enable = true;

        #? idk
        alwaysAnimate.enable = true;
        secretRingToneEnabler.enable = true;
      };
    };
  };

  home.packages = with pkgs; [
    (replaceDependencies {
      drv = ayugram-desktop;
      replacements =
        let
          patchesRepo = pkgs.fetchFromGitHub {
            # https://github.com/desktop-app/patches/tree/0b68b11048987a68d31b2d8380d9b7c5116aa961
            owner = "desktop-app";
            repo = "patches";
            rev = "0b68b11048987a68d31b2d8380d9b7c5116aa961";
            hash = "sha256-eSIO7ALsC8W4bR/KOk7kgDMd9/ABNN8EdCiJwVAK24g=";
          };
          qtbasePatches = pkgs.lib.filesystem.listFilesRecursive "${patchesRepo}/qtbase_6.10.0";
          qtwaylandPatches = pkgs.lib.filesystem.listFilesRecursive "${patchesRepo}/qtwayland_6.10.0";
        in
        [
          {
            oldDependency = qt6.qtbase;
            newDependency = qt6.qtbase.overrideAttrs (oldAttrs: {
              patches = (oldAttrs.patches or [ ]) ++ qtbasePatches;
            });
          }
          {
            oldDependency = qt6.qtwayland;
            newDependency = qt6.qtwayland.overrideAttrs (oldAttrs: {
              patches =
                (oldAttrs.patches or [ ])
                ++ [ (builtins.elemAt qtwaylandPatches 0) ]
                ++ [ (builtins.elemAt qtwaylandPatches 1) ]
                # ++ [ (builtins.elemAt qtwaylandPatches 2) ] # compilation error
                ++ [ ];
            });
          }
        ];
    })
    element-desktop
  ];
}
