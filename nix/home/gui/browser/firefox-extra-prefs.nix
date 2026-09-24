{
  lib,
  pkgs,
  config,
  ...
}:
#? vibecoded solution for firefox extensions settings declaration:
#? to apply them without `programs.firefox.profiles.default.extensions.force = true`
let
  cfg = config.custom.firefox;

  unsignedExtensionsScript = pkgs.writeText "firefox-unsigned-extensions.js" /* javascript */ ''
    {
      const { AddonManager } = ChromeUtils.importESModule(
        "resource://gre/modules/AddonManager.sys.mjs"
      );
      Cu.importGlobalProperties(["IOUtils", "PathUtils"]);

      const extensionDirs = ${builtins.toJSON (map (pkg: "${pkg}") cfg.unsignedExtensions)};

      const installUnsignedExtensions = async () => {
        for (const extPath of extensionDirs) {
          try {
            let id = null;
            try {
              const manifest = await IOUtils.readJSON(PathUtils.join(extPath, "manifest.json"));
              id = manifest?.browser_specific_settings?.gecko?.id
                ?? manifest?.applications?.gecko?.id;
            } catch (_) {}

            if (id) {
              const existing = await AddonManager.getAddonByID(id);
              if (existing) continue;
            }

            const dir = Cc["@mozilla.org/file/local;1"].createInstance(Ci.nsIFile);
            dir.initWithPath(extPath);
            await AddonManager.installTemporaryAddon(dir);
          } catch (error) {
            Cu.reportError(error);
          }
        }
      };

      const observer = {
        observe() {
          Services.obs.removeObserver(observer, "browser-delayed-startup-finished");
          installUnsignedExtensions().catch(Cu.reportError);
        },
      };

      Services.obs.addObserver(observer, "browser-delayed-startup-finished");
    }
  '';

  settingsFile = "${config.xdg.configHome}/firefox-extension-settings.json";

  extensionStorageScript = pkgs.writeText "firefox-extension-storage-settings.js" /* javascript */ ''
    {
      Cu.importGlobalProperties(["IOUtils"]);
      const { AddonManager } = ChromeUtils.importESModule(
        "resource://gre/modules/AddonManager.sys.mjs"
      );
      const { ExtensionParent } = ChromeUtils.importESModule(
        "resource://gre/modules/ExtensionParent.sys.mjs"
      );
      const { ExtensionStorageIDB } = ChromeUtils.importESModule(
        "resource://gre/modules/ExtensionStorageIDB.sys.mjs"
      );

      const settingsFile = ${builtins.toJSON settingsFile};
      const lastApplied = new Map();

      const applyExtensionSettings = async () => {
        let allSettings;
        try {
          allSettings = await IOUtils.readJSON(settingsFile);
        } catch (_) {
          return;
        }

        for (const [extId, settings] of Object.entries(allSettings)) {
          const settingsJSON = JSON.stringify(settings);
          if (lastApplied.get(extId) === settingsJSON) continue;

          const extension = ExtensionParent.WebExtensionPolicy.getByID(extId)?.extension;
          if (!extension) continue;

          try {
            const principal = ExtensionStorageIDB.getStoragePrincipal(extension);
            const storage = await ExtensionStorageIDB.open(
              principal,
              extension.hasPermission("unlimitedStorage")
            );
            let changes;
            try {
              changes = await storage.set(settings);
            } finally {
              storage.close();
            }
            lastApplied.set(extId, settingsJSON);
            if (changes) {
              ExtensionStorageIDB.notifyListeners(extId, changes);
              if (extId === "FirefoxColor@mozilla.com") {
                const addon = await AddonManager.getAddonByID(extId);
                await addon?.reload();
              }
            }
          } catch (err) {
            Cu.reportError(err);
          }
        }
      };

      const observer = {
        observe() {
          Services.obs.removeObserver(observer, "browser-delayed-startup-finished");
          applyExtensionSettings().catch(Cu.reportError);

          const pollTimer = Cc["@mozilla.org/timer;1"].createInstance(Ci.nsITimer);
          pollTimer.initWithCallback(
            () => applyExtensionSettings().catch(Cu.reportError),
            3000,
            Ci.nsITimer.TYPE_REPEATING_SLACK
          );
          Services._extensionStorageTimer = pollTimer;
        },
      };
      Services.obs.addObserver(observer, "browser-delayed-startup-finished");
    }
  '';

  closeWelcomeTabsScript = pkgs.writeText "firefox-intercept-welcome-tabs.js" /* javascript */ ''
    // intercept extension tabs.create calls during ADDON_INSTALL and block welcome tabs
    try {
      const { ExtensionParent } = ChromeUtils.importESModule(
        "resource://gre/modules/ExtensionParent.sys.mjs"
      );

      const browserWelcomePatterns = [
        "about:welcome",
        "color.firefox.com",
      ];

      const patchTabsApiInstance = (api) => {
        if (!api || api._tabsCreatePatched) return;
        api._tabsCreatePatched = true;

        const origGetAPI = api.getAPI;
        api.getAPI = function(context) {
          const res = origGetAPI.apply(this, arguments);
          if (res?.tabs?.create && !res.tabs.create._intercepted) {
            const origCreate = res.tabs.create;
            res.tabs.create = function(createProperties) {
              const extension = context?.extension;
              const isInstall = extension?.startupReason === "ADDON_INSTALL";
              const isZeroOmegaBg = extension?.id === "suziwen1@gmail.com" && context?.viewType === "background";
              const url = createProperties?.url || "";

              if (isInstall || (isZeroOmegaBg && url.includes("options.html"))) {
                if (extension?.id === "suziwen1@gmail.com") {
                  try {
                    context.cloneScope?.localStorage?.setItem("omega.local.firstRun", '""');
                  } catch (_) {}
                }
                const win = Services.wm.getMostRecentWindow("navigator:browser");
                const activeTab = win?.gBrowser?.selectedTab;
                const fakeTab = (activeTab && extension?.tabManager)
                  ? extension.tabManager.convert(activeTab)
                  : { id: -1, index: 0, windowId: -1, url, active: false };
                return Promise.resolve(fakeTab);
              }

              return origCreate.apply(this, arguments);
            };
            res.tabs.create._intercepted = true;
          }
          return res;
        };
      };

      if (ExtensionParent.apiManager) {
        const origGetAPI = ExtensionParent.apiManager.getAPI.bind(ExtensionParent.apiManager);
        ExtensionParent.apiManager.getAPI = function(name, extension, scope) {
          const api = origGetAPI.apply(this, arguments);
          if (name === "tabs") {
            patchTabsApiInstance(api);
          }
          return api;
        };

        const origAsyncGetAPI = ExtensionParent.apiManager.asyncGetAPI.bind(ExtensionParent.apiManager);
        ExtensionParent.apiManager.asyncGetAPI = async function(name, extension, scope) {
          const api = await origAsyncGetAPI.apply(this, arguments);
          if (name === "tabs") {
            patchTabsApiInstance(api);
          }
          return api;
        };
      }

      // fallback: intercept gBrowser.addTab for direct window opens
      const attachToWindow = (win) => {
        try {
          if (!win || !win.gBrowser || win.gBrowser._addTabPatched) return;
          win.gBrowser._addTabPatched = true;
          const origAddTab = win.gBrowser.addTab;
          win.gBrowser.addTab = function(url, options) {
            const urlStr = typeof url === "string" ? url : url?.spec || "";
            if (browserWelcomePatterns.some(p => urlStr.includes(p))) {
              const tab = origAddTab.apply(this, arguments);
              Services.tm.dispatchToMainThread(() => {
                try { win.gBrowser.removeTab(tab, { animate: false }); } catch (_) {}
              });
              return tab;
            }
            return origAddTab.apply(this, arguments);
          };
        } catch (_) {}
      };

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
  frameScript = /* javascript */ ''
    (async () => {
      const urls = ${builtins.toJSON cfg.userscripts};
      const win = content.wrappedJSObject || content;
      if (!win) return;

      const sleep = ms => new Promise(r => (win.setTimeout || setTimeout)(r, ms));

      for (let i = 0; i < 30; i++) {
        if (typeof win.handleCommandMessage === "function") break;
        await sleep(500);
      }
      if (typeof win.handleCommandMessage !== "function") return;

      for (const url of urls) {
        try {
          let fetchUrl = url;
          if (/^(https?:\/\/(?:[a-z0-9_.-]+\.)?(?:greasyfork|sleazyfork)\.org\/(?:[a-zA-Z-]+\/)?scripts\/\d+(?:-[^/]+)?)\/?$/.test(url)) {
            fetchUrl = url.replace(/\/?$/, "/code.user.js");
          }
          const res = await win.fetch(fetchUrl);
          if (!res.ok) {
            sendAsyncMessage("VM:Log", "fetch failed for " + fetchUrl + ": " + res.status);
            continue;
          }
          const code = await res.text();
          const message = {
            cmd: "ParseScript",
            data: { code, url: fetchUrl, bumpDate: true },
          };
          const opts = { fake: true };
          const clonedMsg = typeof Cu !== "undefined" && Cu.cloneInto ? Cu.cloneInto(message, win) : message;
          const clonedOpts = typeof Cu !== "undefined" && Cu.cloneInto ? Cu.cloneInto(opts, win) : opts;
          const resInstall = await win.handleCommandMessage(
            clonedMsg,
            clonedOpts
          );
          sendAsyncMessage("VM:Log", "installed: " + fetchUrl + " -> " + JSON.stringify(resInstall?.where || "ok"));
          await sleep(300);
        } catch (err) {
          sendAsyncMessage("VM:Log", "install error for " + url + ": " + err);
        }
      }
    })().catch(e => sendAsyncMessage("VM:Log", "fatal frame error: " + e));
  '';

  userscriptsScript = pkgs.writeText "firefox-userscripts.js" /* javascript */ ''
    // auto-install declarative userscripts into violentmonkey
    {
      Cu.importGlobalProperties(["IOUtils"]);
      const { ExtensionParent } = ChromeUtils.importESModule(
        "resource://gre/modules/ExtensionParent.sys.mjs"
      );

      let installed = false;

      const log = async (msg) => {
        try {
          Services.console.logStringMessage("[VM:Userscripts] " + msg);
          await IOUtils.writeUTF8(
            "/tmp/userscripts.log",
            msg + "\n",
            { mode: "appendOrCreate" }
          );
        } catch (_) {}
      };

      const installUserscripts = async () => {
        if (installed) return;
        const ext = ExtensionParent.WebExtensionPolicy.getByID("{aecec67f-0d10-4fa7-b7c7-609a2db280cf}")?.extension;
        if (!ext) {
          await log("installUserscripts: extension not found yet");
          return;
        }

        let bgView = null;
        for (const view of ext.views) {
          if (view.viewType === "background" && (view.parentMessageManager || view.xulBrowser?.messageManager)) {
            bgView = view;
            break;
          }
        }
        if (!bgView) {
          await log("installUserscripts: bgView not found, views count = " + (ext.views ? ext.views.size : 0));
          return;
        }

        const mm = bgView.parentMessageManager || bgView.xulBrowser?.messageManager;
        if (!mm || typeof mm.loadFrameScript !== "function") {
          await log("installUserscripts: loadFrameScript not a function on mm");
          return;
        }

        installed = true;
        await log("installUserscripts: injecting frameScript into Violentmonkey");

        mm.addMessageListener("VM:Log", (msg) => {
          log(String(msg?.data || msg));
        });

        mm.loadFrameScript(
          "data:application/javascript;charset=utf-8," + encodeURIComponent(${builtins.toJSON frameScript}),
          false
        );
      };

      const observer = {
        observe() {
          Services.obs.removeObserver(observer, "browser-delayed-startup-finished");
          installUserscripts().catch(Cu.reportError);
        },
      };
      Services.obs.addObserver(observer, "browser-delayed-startup-finished");

      let checks = 45;
      const timer = Cc["@mozilla.org/timer;1"].createInstance(Ci.nsITimer);
      timer.initWithCallback(() => {
        if (installed || --checks <= 0) {
          timer.cancel();
          Services._violentmonkeyUserscriptsTimer = null;
          return;
        }
        installUserscripts().catch(Cu.reportError);
      }, 1000, Ci.nsITimer.TYPE_REPEATING_SLACK);
      Services._violentmonkeyUserscriptsTimer = timer;
    }
  '';
in
{
  options.custom.firefox = {
    extraPrefsFiles = lib.mkOption {
      type = lib.types.listOf lib.types.path;
      default = [ ];
      description = "Extra autoconfig / prefs scripts for firefox";
    };

    unsignedExtensions = lib.mkOption {
      type = lib.types.listOf lib.types.package;
      default = [ ];
      description = "Packages with unpacked webextensions to install on startup";
    };

    extensionStorageSettings = lib.mkOption {
      type = lib.types.attrsOf (lib.types.attrsOf lib.types.anything);
      default = { };
      description = "Declarative settings injected directly into ExtensionStorageIDB without breaking IDB globally";
    };

    closeWelcomeTabs = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Auto-close extension welcome/changelog tabs on startup";
    };

    userscripts = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      description = "Userscript urls to automatically install into violentmonkey on startup";
    };
  };

  config = {
    custom.firefox.extraPrefsFiles =
      lib.optional (cfg.unsignedExtensions != [ ]) unsignedExtensionsScript
      ++ lib.optional (cfg.extensionStorageSettings != { }) extensionStorageScript
      ++ lib.optional cfg.closeWelcomeTabs closeWelcomeTabsScript
      ++ lib.optional (cfg.userscripts != [ ]) userscriptsScript;

    xdg.configFile = lib.mkIf (cfg.extensionStorageSettings != { }) {
      "firefox-extension-settings.json".text = builtins.toJSON cfg.extensionStorageSettings;
    };

    programs.firefox.package = lib.mkIf (cfg.extraPrefsFiles != [ ]) (
      pkgs.firefox.override {
        extraPrefsFiles = config.custom.firefox.extraPrefsFiles;
      }
    );
  };
}
