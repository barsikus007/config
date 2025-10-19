{
  lib,
  pkgs,
  config,
  ...
}:
{
  xdg.mimeApps = {
    defaultApplications = {
      # "application/x-desktop" = [WezTerm.desktop];
    }
    //
      lib.genAttrs
        [
          # "default-web-browser"
          # "x-scheme-handler/about"
          # "x-scheme-handler/unknown"
          "application/pdf"
          "application/x-extension-htm"
          "application/x-extension-html"
          "application/x-extension-shtml"
          "application/x-extension-xht"
          "application/x-extension-xhtml"
          "text/html"
          "x-scheme-handler/chrome"
          "x-scheme-handler/http"
          "x-scheme-handler/https"
        ]
        (key: [
          "firefox.desktop"
          "microsoft-edge.desktop"
          # "com.microsoft.Edge.desktop"
        ]);
    associations.removed = {
      "application/xhtml+xml" = [
        "firefox.desktop"
        "microsoft-edge.desktop"
        "com.microsoft.Edge.desktop"
      ];
    };
  };

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
      #? no thorium? https://github.com/NixOS/nixpkgs/pull/336138#issuecomment-2299603455
      pkgs.microsoft-edge.override {
        # https://wiki.nixos.org/wiki/Chromium#Accelerated_video_playback
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
    # nix run github:tupakkatapa/mozid -- '<url>'
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
        (extension "violentmonkey" "{aecec67f-0d10-4fa7-b7c7-609a2db280cf}")
        (extension "sponsorblock" "sponsorBlocker@ajay.app")
        (extension "return-youtube-dislikes" "{762f9885-5a13-4abd-9c77-433dcd38b8fd}")
        (extension "search_by_image" "{2e5ff8c8-32fe-46d0-9fc8-6b8986621f3c}")
        (extension "text-fragment" "text-fragment@example.com")
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
          "general.autoScroll" = true; # middle click scroll
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

          # disable ads and telemetry for privacy reasons
          "browser.newtabpage.activity-stream.showSponsored" = false;
          "browser.newtabpage.activity-stream.showSponsoredTopSites" = false;
          "toolkit.telemetry.archive.enabled" = false;
          "toolkit.telemetry.enabled" = false; # enforced by nixos
          "toolkit.telemetry.server" = "";
          "toolkit.telemetry.unified" = false;
          "extensions.webcompat-reporter.enabled" = false; # don't report compability problems to mozilla
          "datareporting.policy.dataSubmissionEnabled" = false;
          "datareporting.healthreport.uploadEnabled" = false;
          "browser.ping-centre.telemetry" = false;
          "browser.urlbar.eventTelemetry.enabled" = false; # (default)
        };
        # Hide tab bar because we have tree style tabs
        #! https://mrotherguy.github.io/firefox-csshacks/?file=hide_tabs_toolbar_v2.css
        userChrome = pkgs.fetchurl {
          url = "https://raw.githubusercontent.com/MrOtherGuy/firefox-csshacks/9bb5b59e3ad2b42483731203d51f6cb758fa6cb5/chrome/hide_tabs_toolbar_v2.css";
          hash = "sha256-xP2UqInVthDB67/hU9/rY1jEYXJs+R+i1qDn3LVts6Y=";
        };

        search = {
          force = true;
          default = "google";
          privateDefault = "google";
          # TODO: steal: https://github.com/Bwc9876/nix-conf/blob/8caed4590cd7981933a0833d59d0dac1c9ab90d5/home/firefox.nix#L84
          engines = {
            # builtins only supports adding alias or hiding
            google.metaData.alias = "g";
            # tabs.metaData.alias = "t"; #! tabs doesnt work for some reason!!!
            bing.metaData.hidden = true;
            #? Search engines are now referenced by id instead of by name, use 'youtube' instead of 'YouTube' -_-
            youtube = {
              urls = [
                {
                  template = "https://www.youtube.com/results";
                  params = [
                    {
                      name = "search_query";
                      value = "{searchTerms}";
                    }
                  ];
                }
              ];

              iconMapObj."32" = "https://www.google.com/s2/favicons?sz=32&domain=youtube.com";
              definedAliases = [ "y" ];
            };
            "Nix Packages" = {
              urls = [
                {
                  template = "https://search.nixos.org/packages";
                  params = [
                    {
                      name = "channel";
                      # TODO should be system version
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
                      # TODO should be system version
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
            "Anime" = {
              urls = [
                {
                  template = "https://site.yummyani.me/search";
                  params = [
                    {
                      name = "word";
                      value = "{searchTerms}";
                    }
                  ];
                }
              ];

              iconMapObj."32" = "https://site.yummyani.me/favicon.ico";
              definedAliases = [ "a" ];
            };
            "Shikimori" = {
              urls = [
                {
                  template = "https://shikimori.one/animes";
                  params = [
                    {
                      name = "search";
                      value = "{searchTerms}";
                    }
                  ];
                }
              ];

              iconMapObj."32" = "https://shikimori.one/favicon.ico";
              definedAliases = [ "aa" ];
            };
            "Web Archive" = {
              urls = [ { template = "https://web.archive.org/web/20250000000000*/{searchTerms}"; } ];
              iconMapObj."32" = "https://web-static.archive.org/_static/images/archive.ico";
              definedAliases = [ "ar" ];
            };
            "Grok" = {
              urls = [
                {
                  template = "https://grok.com";
                  params = [
                    {
                      name = "q";
                      value = "{searchTerms}";
                    }
                  ];
                }
              ];

              iconMapObj."32" = "https://grok.com/images/favicon-dark.png";
              definedAliases = [ "gr" ];
            };
            "GitHub" = {
              urls = [
                {
                  template = "https://github.com/search";
                  params = [
                    {
                      name = "q";
                      value = "{searchTerms}";
                    }
                    {
                      name = "type";
                      value = "code";
                    }
                  ];
                }
              ];

              iconMapObj."32" = "https://github.com/favicons/favicon.svg";
              definedAliases = [ "gi" ];
            };
            "GitHub Nix" = {
              urls = [
                {
                  template = "https://github.com/search";
                  params = [
                    {
                      name = "q";
                      value = "lang:nix {searchTerms}";
                    }
                    {
                      name = "type";
                      value = "code";
                    }
                  ];
                }
              ];

              iconMapObj."32" = "https://github.com/favicons/favicon.svg";
              definedAliases = [ "gin" ];
            };
            "Yandex Maps" = {
              urls = [
                {
                  template = "https://yandex.ru/maps?mode=search&text=пиво";
                  params = [
                    {
                      name = "mode";
                      value = "search";
                    }
                    {
                      name = "text";
                      value = "{searchTerms}";
                    }
                  ];
                }
              ];

              iconMapObj."32" = "https://yandex.ru/maps/favicon.svg";
              definedAliases = [ "ym" ];
            };

            #? it wont work for some strange google reason
            # "YouTube History" = {
            #   urls = [
            #     {
            #       template = "https://www.youtube.com/feed/history";
            #       params = [
            #         {
            #           name = "query";
            #           value = "{searchTerms}";
            #         }
            #       ];
            #     }
            #   ];

            #   definedAliases = [ "yh" ];
            # };
          };
        };
      };
    };
  };
}
