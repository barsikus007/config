{
  lib,
  pkgs,
  ...
}:
let
  closeWelcomeTabs = pkgs.writeText "close-welcome-tabs.js" /* javascript */ ''
    // auto-close extension welcome and changelog tabs on startup
    try {
      const welcomePatterns = [
        "setup/install.html",
        "darkreader.org/help",
        "zakilo.syrnikovpavel.ru",
        "changelog",
        "options.html#!/about",
        "help/index.html",
        "about:welcome",
      ];

      const closeMatchingTabs = (win) => {
        try {
          if (!win || !win.gBrowser) return;
          for (const tab of Array.from(win.gBrowser.tabs)) {
            const url = tab.linkedBrowser?.currentURI?.spec || "";
            if (url && welcomePatterns.some(p => url.includes(p))) {
              win.gBrowser.removeTab(tab);
            }
          }
        } catch (_) {}
      };

      const attachToWindow = (win) => {
        try {
          if (!win || !win.gBrowser) return;
          closeMatchingTabs(win);

          win.gBrowser.tabContainer.addEventListener("TabOpen", (e) => {
            const tab = e.target;
            const b = tab?.linkedBrowser;
            if (!b) return;
            const check = () => {
              try {
                const url = b.currentURI?.spec || "";
                if (url && welcomePatterns.some(p => url.includes(p))) {
                  win.gBrowser.removeTab(tab);
                }
              } catch (_) {}
            };
            b.addEventListener("DOMContentLoaded", check, { once: true });
            b.addEventListener("load", check, { once: true });
          });
        } catch (_) {}
      };

      // poll periodically during startup (first 45 seconds) to catch delayed tabs
      let remainingChecks = 45;
      const startupTimer = Cc["@mozilla.org/timer;1"].createInstance(Ci.nsITimer);
      startupTimer.initWithCallback(() => {
        try {
          for (const win of Services.wm.getEnumerator("navigator:browser")) {
            closeMatchingTabs(win);
          }
        } catch (_) {}
        remainingChecks--;
        if (remainingChecks <= 0) {
          startupTimer.cancel();
        }
      }, 1000, Ci.nsITimer.TYPE_REPEATING_SLACK);

      const observer = {
        observe(subject, topic) {
          if (topic === "browser-delayed-startup-finished") {
            attachToWindow(subject);
          }
        }
      };

      Services.obs.addObserver(observer, "browser-delayed-startup-finished");

      for (const win of Services.wm.getEnumerator("navigator:browser")) {
        attachToWindow(win);
      }
    } catch (e) {
      Cu.reportError(e);
    }
  '';

  mkPngDataUri =
    file:
    "data:image/png;base64,${builtins.readFile (
      pkgs.runCommand "icon-b64" { } "${pkgs.coreutils}/bin/base64 -w0 ${file} > $out"
    )}";
in
{
  #! wl-paste | nix run nixpkgs#yaml2nix -- /dev/stdin | nix run nixpkgs#nixfmt -- - | wl-copy
  programs.firefox = {
    package = lib.mkForce (
      pkgs.firefox.override {
        extraPrefsFiles = [ closeWelcomeTabs ];
      }
    );

    policies = {
      "3rdparty".Extensions = {
        "{3c078156-979c-498b-8990-85f7987dd929}" = {
          sidebar = {
            panels = {
              # id: RUHiPaWiBy3N
              tabs = {
                type = 2;
                id = "tabs";
                name = "Tabs";
                color = "toolbar";
                iconSVG = "icon_tabs";
              };
              # id: zL3EI5UPSo4N
              video = {
                type = 2;
                id = "video";
                name = "Video";
                color = "red";
                iconSVG = "icon_play";
                noEmpty = false;
                newTabCtx = "none";
                dropTabCtx = "none";
                moveRules = [
                  {
                    id = "youtube"; # 9mqCqM0imq5N
                    active = true;
                    url = "youtube.com";
                    topLvlOnly = true;
                  }
                ];
              };
              # id: 0_0KkU2KWM5N
              nix = {
                type = 2;
                id = "nix";
                name = "Nix";
                color = "blue";
                iconSVG = "icon_circle";
                iconIMGSrc = "";
                iconIMG = mkPngDataUri "${pkgs.nixos-icons}/share/icons/hicolor/16x16/apps/nix-snowflake.png";
              };
              # id: JFZxrxUT667N
              nas = {
                type = 2;
                id = "nas";
                name = "NAS";
                color = "yellow";
                iconSVG = "fence";
              };
              # id: PVyBcdy41l9N
              vpn = {
                type = 2;
                id = "vpn";
                name = "VPN";
                color = "purple";
                iconSVG = "vacation";
              };
              # id: ZO-kq4dcge-N
              dev = {
                type = 2;
                id = "dev";
                name = "Dev";
                color = "turquoise";
                iconSVG = "icon_code";
              };
              # id: G78gZSdBENlm
              bookmarks = {
                type = 2;
                id = "bookmarks";
                name = "Bookmarks";
                color = "green";
                iconSVG = "icon_book";
                bookmarksFolderId = "toolbar_____";
              };
            };
            nav = [
              "tabs" # RUHiPaWiBy3N
              "video" # zL3EI5UPSo4N
              "nix" # 0_0KkU2KWM5N
              "nas" # JFZxrxUT667N
              "vpn" # PVyBcdy41l9N
              "dev" # ZO-kq4dcge-N
              "bookmarks" # G78gZSdBENlm
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
  };

  # pre-grant optional permissions so firefox skips approval prompts
  xdg.configFile."mozilla/firefox/default/extension-preferences.json" = {
    force = true;
    text = builtins.toJSON {
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
