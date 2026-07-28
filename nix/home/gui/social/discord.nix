{
  lib,
  pkgs,
  inputs,
  options,
  ...
}:
let
  #! discord grabs the nvidia dGPU and never lets go: starting a stream makes its renderer
  #! dlopen libcuda + libnvidia-encode (NVENC) and open /dev/nvidia0, and those fds survive
  #! leaving the stream - the card stays in D0 until discord itself exits
  #? three separate paths have to be shut, one env var each:
  #?   CUDA_VISIBLE_DEVICES=""        - cuInit() returns 100 (no device), no /dev/nvidia* fds at all
  #?   VK_LOADER_DRIVERS_DISABLE      - hides nvidia_icd from the vulkan loader (webgpu/ANGLE-vulkan)
  #?   __EGL_VENDOR_LIBRARY_FILENAMES - glvnd sees only mesa, so EGL cannot land on nvidia
  #! renderD128 (amdgpu) is left alone, so compositing still runs on the Vega iGPU as before
  #? mesa path, not /run/opengl-driver: this is a home-manager module, no hardware.graphics here
  igpuOnly = {
    CUDA_VISIBLE_DEVICES = "";
    VK_LOADER_DRIVERS_DISABLE = "*nvidia*";
    __EGL_VENDOR_LIBRARY_FILENAMES = "${pkgs.mesa}/share/glvnd/egl_vendor.d/50_mesa.json";
  };

  #? postFixup on the package option, so nixcord still does its own .override on top
  #? (vencord/openASAR/commandLineArgs) - the wrapper survives it
  pinToIgpu =
    package:
    package.overrideAttrs (old: {
      postFixup = (old.postFixup or "") + ''
        for b in "$out"/bin/*; do
          wrapProgram "$b" ${
            lib.concatStringsSep " " (lib.mapAttrsToList (n: v: "--set ${n} '${v}'") igpuOnly)
          }
        done
      '';
    });
in
{
  imports = [ inputs.nixcord.homeModules.default ];

  xdg.desktopEntries.discord-url = {
    name = "Discord - URL Handler";
    exec = "Discord --url -- %u";
    icon = "discord";
    terminal = false;
    noDisplay = true;
    mimeType = [ "x-scheme-handler/discord" ];
  };

  xdg.mimeApps = {
    defaultApplications = {
      "x-scheme-handler/discord" = [
        "discord-url.desktop"
        # "vesktop.desktop"
        # "dorion.desktop"
      ];
    };
  };

  xdg.configFile."handlr/handlr.toml".text = /* toml */ ''
    [[handlers]]
    exec = 'bash -c "x=%u; discord --url -- discord://''${x#*://}"'
    regexes = ['^https://(www\.)?discord\.com/.*']
  '';

  programs.nixcord = {
    enable = true;
    discord = {
      # enable = false;
      # branch = "canary";
      vencord.enable = true;
      commandLineArgs = [ "--enable-blink-features=MiddleClickAutoscroll" ];
      openASAR.enable = false;
      #! keep discord off the nvidia dGPU (see pinToIgpu)
      #? wrap nixcord's own default package, not pkgs.discord - nixcord re-overrides it with
      #? `branch`, which plain pkgs.discord does not accept
      package = pinToIgpu options.programs.nixcord.discord.package.default;
    };
    vesktop = {
      enable = true;
      autoscroll.enable = true;
      #! same dGPU grab as discord (see pinToIgpu)
      package = pinToIgpu pkgs.vesktop;
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
}
