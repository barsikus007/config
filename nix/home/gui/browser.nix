{ pkgs, config, ... }:
{
  home.packages = with pkgs; [
    # TODO firefoxpwa
    (microsoft-edge.override {
      # https://wiki.nixos.org/wiki/Chromium#Accelerated_video_playback
      commandLineArgs = [
        "--enable-features=AcceleratedVideoEncoder"
        "--ignore-gpu-blocklist"
        "--enable-zero-copy"
      ];
    })
  ];
  programs.chromium = {
    enable = true;
    extensions = [
      # https://chromewebstore.google.com/detail/ublock-origin/cjpalhdlnbpafiamejdnhcphjbkeiagm
      "cjpalhdlnbpafiamejdnhcphjbkeiagm"
      # https://chromewebstore.google.com/detail/violentmonkey/jinjaccalgkegednnccohejagnlnfdag
      "jinjaccalgkegednnccohejagnlnfdag"
      # https://chromewebstore.google.com/detail/keepassxc-browser/oboonakemofpalcgghocfoadofidjkkk
      "oboonakemofpalcgghocfoadofidjkkk"
    ];
    package = (
      pkgs.chromium.override {
        commandLineArgs = [
          "--enable-features=AcceleratedVideoEncoder"
          "--ignore-gpu-blocklist"
          "--enable-zero-copy"
        ];
      }
    );
  };
  programs.firefox = {
    enable = true;
    nativeMessagingHosts = [ pkgs.firefoxpwa ];
    # https://github.com/tupakkatapa/mozid
    # nix run github:tupakkatapa/mozid -- <url>
    policies.ExtensionSettings =
      let
        extension = shortId: uuid: {
          name = uuid;
          value = {
            install_url = "https://addons.mozilla.org/en-US/firefox/downloads/latest/${shortId}/latest.xpi";
            installation_mode = "normal_installed";
          };
        };
      in
      builtins.listToAttrs [
        (extension "pwas-for-firefox" "firefoxpwa@filips.si")
        (extension "sidebery" "{3c078156-979c-498b-8990-85f7987dd929}")
        (extension "ublock-origin" "uBlock0@raymondhill.net")
        (extension "keepassxc-browser" "keepassxc-browser@keepassxc.org")
        (extension "zeroomega" "suziwen1@gmail.com")
        (extension "darkreader" "addon@darkreader.org")
        # (extension "bitwarden-password-manager" "{446900e4-71c2-419f-a6a7-df9c091e268b}")
        # (extension "umatrix" "uMatrix@raymondhill.net")
        # (extension "libredirect" "7esoorv3@alefvanoon.anonaddy.me")
        # (extension "clearurls" "{74145f27-f039-47ce-a470-a662b129930a}")
      ];
    profiles = {
      default = {
        id = 0;
        isDefault = true;
        # https://github.com/oddlama/nix-config/blob/main/users/myuser/graphical/firefox.nix
        settings = {
          "widget.use-xdg-desktop-portal.file-picker" = 1;
          "general.autoScroll" = true;
          "browser.ctrlTab.sortByRecentlyUsed" = true; # mru ^Tab
          "browser.startup.page" = 3; # Resume previous session on startup
          "browser.translations.neverTranslateLanguages" = "ru";
          # "devtools.chrome.enabled" = true; # Allow executing JS in the dev console
          # "browser.uitour.enabled" = false; # no tutorial please
          # https://github.com/FirefoxCSS-Store/FirefoxCSS-Store.github.io/blob/main/README.md#generic-installation
          "toolkit.legacyUserProfileCustomizations.stylesheets" = true;
          "layers.acceleration.force-enabled" = true;
          "gfx.webrender.all" = true;
          "gfx.webrender.enabled" = true;
          "layout.css.backdrop-filter.enabled" = true;
          "svg.context-properties.content.enabled" = true;
        };
        # Hide tab bar because we have tree style tabs
        #! https://github.com/mbnuqw/sidebery/wiki/Firefox-Styles-Snippets-(via-userChrome.css)#dynamic-native-tabs-for-hiding-native-horizontal-tabs
        userChrome = /* css */ ''
          /**
           * Decrease size of the sidebar header
           */
          #sidebar-header {
            font-size: 1.2em !important;
            padding: 2px 6px 2px 3px !important;
          }
          #sidebar-header #sidebar-close {
            padding: 3px !important;
          }
          #sidebar-header #sidebar-close .toolbarbutton-icon {
            width: 14px !important;
            height: 14px !important;
            opacity: 0.6 !important;
          }

          // same as below but without conditions
          #TabsToolbar {
            visibility: collapse !important;
          }
          #titlebar-buttonbox {
            height: 32px !important;
          }

          /**
           * Dynamic Horizontal Tabs Toolbar (with animations)
           * sidebar.verticalTabs: false (with native horizontal tabs)
           */
          #main-window #TabsToolbar > .toolbar-items {
            overflow: hidden;
            transition: height 0.3s 0.3s !important;
          }
          /* Default state: Set initial height to enable animation */
          #main-window #TabsToolbar > .toolbar-items { height: 3em !important; }
          #main-window[uidensity="touch"] #TabsToolbar > .toolbar-items { height: 3.35em !important; }
          #main-window[uidensity="compact"] #TabsToolbar > .toolbar-items { height: 2.7em !important; }
          /* Hidden state: Hide native tabs strip */
          #main-window[titlepreface*="[Sidebery]"] #TabsToolbar > .toolbar-items { height: 0 !important; }
          /* Hidden state: Fix z-index of active pinned tabs */
          #main-window[titlepreface*="[Sidebery]"] #tabbrowser-tabs { z-index: 0 !important; }
          /* Hidden state: Hide window buttons in tabs-toolbar */
          #main-window[titlepreface*="[Sidebery]"] #TabsToolbar .titlebar-spacer,
          #main-window[titlepreface*="[Sidebery]"] #TabsToolbar .titlebar-buttonbox-container {
            display: none !important;
          }
          /* [Optional] Uncomment block below to show window buttons in nav-bar (maybe, I didn't test it on non-linux-i3wm env) */
          #main-window[titlepreface*="[Sidebery]"] #nav-bar > .titlebar-buttonbox-container,
          #main-window[titlepreface*="[Sidebery]"] #nav-bar > .titlebar-buttonbox-container > .titlebar-buttonbox {
            display: flex !important;
          }
          /* [Optional] Uncomment one of the line below if you need space near window buttons */
          #main-window[titlepreface*="[Sidebery]"] #nav-bar > .titlebar-spacer[type="pre-tabs"] { display: flex !important; } */
          #main-window[titlepreface*="[Sidebery]"] #nav-bar > .titlebar-spacer[type="post-tabs"] { display: flex !important; } */
        '';

        search = {
          force = true;
          default = "Google";
          privateDefault = "Google";
          engines = {
            "Nix Packages" = {
              urls = [
                {
                  template = "https://search.nixos.org/packages";
                  params = [
                    {
                      name = "channel";
                      value = config.home.stateVersion;
                    }
                    {
                      name = "query";
                      value = "{searchTerms}";
                    }
                  ];
                }
              ];

              icon = "${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";
              definedAliases = [ "pac" ];
            };
            "Nix Options" = {
              urls = [
                {
                  template = "https://search.nixos.org/options";
                  params = [
                    {
                      name = "channel";
                      value = config.home.stateVersion;
                    }
                    {
                      name = "query";
                      value = "{searchTerms}";
                    }
                  ];
                }
              ];

              icon = "${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";
              definedAliases = [ "opt" ];
            };
            "Home Manager Options" = {
              urls = [
                {
                  template = "https://home-manager-options.extranix.com/";
                  params = [
                    {
                      name = "release";
                      value = "release-${config.home.stateVersion}";
                    }
                    {
                      name = "query";
                      value = "{searchTerms}";
                    }
                  ];
                }
              ];

              icon = "${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";
              definedAliases = [ "hom" ];
            };
            "NixOS Wiki" = {
              urls = [
                {
                  template = "https://wiki.nixos.org/w/index.php";
                  params = [
                    {
                      name = "search";
                      value = "{searchTerms}";
                    }
                  ];
                }
              ];

              icon = "${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";
              definedAliases = [ "wik" ];
            };
          };
        };
      };
    };
  };
}
