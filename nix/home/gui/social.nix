{
  lib,
  pkgs,
  inputs,
  ...
}:
# Да.
let
  #? t.me paths don't map 1:1 to tg:// - tg:// uses resolve?domain=/join?invite=/etc,
  #? see https://core.telegram.org/api/links for the full mapping
  tgClient = "AyuGram";
  tgMeOpen = pkgs.writeShellApplication {
    name = "tg-me-open";
    text = /* shell */''
      url=$1
      rest=''${url#*://}
      rest=''${rest#*/}
      path="/''${rest%%\?*}"
      query=""
      [[ "$rest" == *\?* ]] && query="''${rest#*\?}"

      case "$path" in
        /+*)
          tguri="tg://join?invite=''${path#/+}"
          ;;
        /joinchat/*)
          tguri="tg://join?invite=''${path#/joinchat/}"
          ;;
        /c/*)
          IFS='/' read -r _ _ channel post _ <<< "$path"
          tguri="tg://privatepost?channel=''${channel}"
          [[ -n "''${post:-}" ]] && tguri="''${tguri}&post=''${post}"
          ;;
        /addstickers/*)
          tguri="tg://addstickers?set=''${path#/addstickers/}"
          ;;
        /addemoji/*)
          tguri="tg://addemoji?set=''${path#/addemoji/}"
          ;;
        *)
          IFS='/' read -r _ domain post _ <<< "$path"
          tguri="tg://resolve?domain=''${domain}"
          [[ "''${post:-}" =~ ^[0-9]+$ ]] && tguri="''${tguri}&post=''${post}"
          ;;
      esac

      if [[ -n "$query" ]]; then
        case "$tguri" in
          *\?*) tguri="''${tguri}&''${query}" ;;
          *) tguri="''${tguri}?''${query}" ;;
        esac
      fi

      exec env DESKTOPINTEGRATION=1 ${tgClient} -- "$tguri"
    '';
  };
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
    }
    // lib.genAttrs [
      "x-scheme-handler/tg"
      "x-scheme-handler/tonsite"
    ] (key: "com.ayugram.desktop.desktop");
  };

  xdg.configFile."handlr/handlr.toml".text = /* toml */ ''
    [[handlers]]
    exec = 'bash -c "x=%u; discord --url -- discord://''${x#*://}"'
    regexes = ['^https://(www\.)?discord\.com/.*']

    [[handlers]]
    exec = "${lib.getExe tgMeOpen} %u"
    regexes = ['^https://(www\.)?(t\.me|telegram\.(me|dog))/.*']
  '';

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
