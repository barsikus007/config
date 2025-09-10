{
  lib,
  pkgs,
  inputs,
  ...
}:
# Да.
let
  patchesRepo = pkgs.fetchFromGitHub {
    # https://github.com/desktop-app/patches/raw/e15b5d87c565e516aad5bcafdfe40315f84e5459
    owner = "desktop-app";
    repo = "patches";
    rev = "e15b5d87c565e516aad5bcafdfe40315f84e5459";
    sha256 = "sha256-p2MQ2V0JQ8QoTb4syd0aFXYBE7MUJdeNmgJHV+Cy1GQ=";
  };
  qtbasePatches = pkgs.lib.filesystem.listFilesRecursive "${patchesRepo}/qtbase_6.9.1";
  qtwaylandPatches = pkgs.lib.filesystem.listFilesRecursive "${patchesRepo}/qtwayland_6.9.1";
in
let
  qtbasePatched = pkgs.qt6.qtbase.overrideAttrs (oldAttrs: {
    patches = (oldAttrs.patches or [ ]) ++ qtbasePatches;
  });
  qtwaylandPatched = pkgs.qt6.qtwayland.overrideAttrs (oldAttrs: {
    patches =
      (oldAttrs.patches or [ ])
      ++ [ (builtins.elemAt qtwaylandPatches 0) ]
      # ++ [ (builtins.elemAt qtwaylandPatches 1) ] # compilation error
      ++ [ (builtins.elemAt qtwaylandPatches 2) ];
    # ++ [ (builtins.elemAt qtwaylandPatches 3) ] # compilation error
    # ++ [ (builtins.elemAt qtwaylandPatches 4) ] # core dumped
  });
in
{
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
    (unstable.ayugram-desktop.overrideAttrs (oldAttrs: {
      qtWrapperArgs = (oldAttrs.qtWrapperArgs or [ ]) ++ [
        "--prefix"
        "LD_LIBRARY_PATH"
        ":"
        (lib.makeLibraryPath [
          qtbasePatched
          qtwaylandPatched
        ])
      ];
    }))
    element-desktop
  ];
}
