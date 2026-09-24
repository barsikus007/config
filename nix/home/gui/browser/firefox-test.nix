{
  pkgs,
  ...
}:
let
  mkPngDataUri =
    file:
    "data:image/png;base64,${
      builtins.readFile (pkgs.runCommand "icon-b64" { } "${pkgs.coreutils}/bin/base64 -w0 ${file} > $out")
    }";
in
{
  custom.firefox = {
    closeWelcomeTabs = true;
    userscripts = [
      #? youtube
      "https://greasyfork.org/en/scripts/390352-youtube-stay-active-and-play-forever"
      "https://greasyfork.org/en/scripts/439993-youtube-shorts-redirect"
      # TODO: replace?
      "https://github.com/Xenorio/YTShareAntiTrack/raw/main/YTShareAntiTrack.user.js"

      "https://greasyfork.org/en/scripts/390352-youtube-stay-active-and-play-forever"
      # "https://greasyfork.org/en/scripts/518509-vk-ads-fixes"
      "https://greasyfork.org/en/scripts/555555-shikimori-404-fix"
      # "https://greasyfork.org/en/scripts/564382-google-gemini-always-switch-to-pro-aggressive"
    ]
    ++ map (_: "https://raw.githubusercontent.com/barsikus007/config/master/browser/userscripts/${_}") [
      "ClaudeInline.user.js"
      #! "ExchangeRater.user.js"
      "GeminiInline.user.js"
      # "LigmaBallz.user.js"
      "NixOSWiki.user.js"
      # "VideoLinkDumper.user.js"
      #! "VKPlayerMaxQuality.user.js"
      "YouTubeFix.user.js"
    ];
    extensionStorageSettings = {
      # dark reader
      "addon@darkreader.org" = {
        enabled = true;
        theme = {
          mode = 1;
          brightness = 100;
          contrast = 100;
          grayscale = 0;
          sepia = 0;
          useFont = false;
          fontFamily = "Open Sans";
          textStroke = 0;
          engine = "dynamicTheme";
          stylesheet = "";
        };
        automation = {
          enabled = false;
          mode = "";
          behavior = "OnOff";
        };
        changeBrowserTheme = false;
      };

      # violentmonkey
      "{aecec67f-0d10-4fa7-b7c7-609a2db280cf}" = {
        autoUpdate = 1;
        showNotification = true;
      };
    };
  };

  programs.firefox = {
    policies = {
      "3rdparty".Extensions = {
        #? https://github.com/mbnuqw/sidebery
        "{3c078156-979c-498b-8990-85f7987dd929}" = {
          /*
            (async () => {
              const data = await browser.storage.local.get(['settings', 'sidebarCSS', 'groupCSS', 'sidebar', 'contextMenu']);

              // загрузка эталонных дефолтов Sidebery v5
              const res = await fetch('https://raw.githubusercontent.com/mbnuqw/sidebery/v5.6.1/src/defaults/settings.ts');
              const txt = await res.text();
              const block = txt.slice(txt.indexOf('DEFAULT_SETTINGS'), txt.indexOf('SETTINGS_OPTIONS'));
              const defs = {};
              for (const line of block.split('\n')) {
                const m = line.match(/^\s*([a-zA-Z0-9_]+):\s*(.+?),?\s*$/);
                if (m) {
                  try { defs[m[1]] = JSON.parse(m[2].replaceAll("'", '"')); } catch {}
                }
              }

              // фильтрация только изменённых параметров
              const diffSettings = {};
              for (const [k, v] of Object.entries(data.settings || {})) {
                if (defs[k] !== undefined && JSON.stringify(v) !== JSON.stringify(defs[k])) {
                  diffSettings[k] = v;
                }
              }

              const result = {
                settings: diffSettings,
                ...(data.sidebarCSS ? { sidebarCSS: data.sidebarCSS } : {}),
                ...(data.groupCSS ? { groupCSS: data.groupCSS } : {}),
              };

              console.log('Изменённые настройки Sidebery:\n', JSON.stringify(result, null, 2));
            })();
          */
          sidebar = {
            panels = {
              panel___tabs = {
                type = 2;
                id = "panel___tabs";
                name = "Tabs";
                color = "toolbar";
                iconSVG = "icon_tabs";
              };
              panel__video = {
                type = 2;
                id = "panel__video";
                name = "Video";
                color = "red";
                iconSVG = "icon_play";
                noEmpty = false;
                newTabCtx = "none";
                dropTabCtx = "none";
                moveRules = [
                  {
                    id = "rule_youtube"; # 9mqCqM0imq5N
                    active = true;
                    url = "youtube.com";
                    topLvlOnly = true;
                  }
                ];
              };
              panel____nix = {
                type = 2;
                id = "panel____nix";
                name = "Nix";
                color = "blue";
                iconSVG = "icon_circle";
                iconIMGSrc = "";
                iconIMG = mkPngDataUri "${pkgs.nixos-icons}/share/icons/hicolor/16x16/apps/nix-snowflake.png";
              };
              panel____nas = {
                type = 2;
                id = "panel____nas";
                name = "NAS";
                color = "yellow";
                iconSVG = "fence";
              };
              panel____vpn = {
                type = 2;
                id = "panel____vpn";
                name = "VPN";
                color = "purple";
                iconSVG = "vacation";
              };
              panel____dev = {
                type = 2;
                id = "panel____dev";
                name = "Dev";
                color = "turquoise";
                iconSVG = "icon_code";
              };
              pa_bookmarks = {
                type = 2;
                id = "pa_bookmarks";
                name = "Bookmarks";
                color = "green";
                iconSVG = "icon_book";
                bookmarksFolderId = "toolbar_____";
              };
            };
            nav = [
              "panel___tabs" # RUHiPaWiBy3N
              "panel__video" # zL3EI5UPSo4N
              "panel____nix" # 0_0KkU2KWM5N
              "panel____nas" # JFZxrxUT667N
              "panel____vpn" # PVyBcdy41l9N
              "panel____dev" # ZO-kq4dcge-N
              "pa_bookmarks" # G78gZSdBENlm
              "add_tp"
              "sp-0"
              "settings"
              "search"
              "collapse"
            ];
          };
        };
      };
    };

    profiles.default.settings = {
      # automatically enable sideloaded extensions from nix store without prompt
      "extensions.autoDisableScopes" = 0;
    };
  };

  # pre-grant optional permissions so firefox skips approval prompts
  xdg.configFile."mozilla/firefox/default/extension-preferences.json" = {
    force = true;
    text = builtins.toJSON {
      "FirefoxColor@mozilla.com" = {
        permissions = [
          "tabs"
          "internal:svgContextPropertiesAllowed"
          "internal:privateBrowsingAllowed"
        ];
        origins = [
          "*://color.firefox.com/*"
          "https://color.firefox.com/*"
        ];
        data_collection = [ ];
      };
      #? https://github.com/mbnuqw/sidebery
      "{3c078156-979c-498b-8990-85f7987dd929}" = {
        permissions = [
          "bookmarks"
          "history"
          "webRequest"
          "webRequestBlocking"
          "proxy"
          "<all_urls>"
          "tabHide"
          "clipboardWrite"
          "downloads"
          "clipboardRead"
          "internal:privateBrowsingAllowed"
        ];
        origins = [ "<all_urls>" ];
        data_collection = [ ];
      };
    };
  };
}
