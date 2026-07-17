{
  lib,
  pkgs,
  inputs,
  ...
}:
# Да.
{
  imports = [ inputs.nixcord.homeModules.default ];

  xdg.mimeApps = {
    defaultApplications = {
      "x-scheme-handler/discord" = [
        # "discord.desktop"
        "vesktop.desktop"
        # "dorion.desktop"
      ];
    }
    // lib.genAttrs [
      "x-scheme-handler/tg"
      "x-scheme-handler/tonsite"
    ] (key: "com.ayugram.desktop.desktop");
  };

  programs.nixcord = {
    enable = true;
    discord = {
      # enable = false;
      # branch = "canary";
      commandLineArgs = [ "--enable-blink-features=MiddleClickAutoscroll" ];
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
        webScreenShareFixes.enable = true;
        showHiddenChannels.enable = true;
        showConnections.enable = true;
        silentTyping.enable = true;
        forceOwnerCrown.enable = true;
        platformIndicators.enable = true;
        permissionFreeWill.enable = true;
        #! breaks loading for now
        # noMosaic.enable = true;
        voiceMessages.enable = true;
        biggerStreamPreview.enable = true;
        greetStickerPicker.enable = true;
        volumeBooster.enable = true;
        youtubeAdblock.enable = true;

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
        copyUserUrls.enable = true;

        #? idk
        alwaysAnimate.enable = true;
        secretRingToneEnabler.enable = true;
      };
    };
  };

  programs.thunderbird = {
    enable = true;
    profiles.default = {
      isDefault = true;
      settings = {
        # "general.useragent.override" = "";
        # "privacy.donottrackheader.enabled" = true;
      };
    };
  };

  home.packages = with pkgs; [
    ayugram-desktop
    # self.legacyPackages.${stdenv.hostPlatform.system}.ayugram-desktop-patched
    element-desktop
  ];
}
