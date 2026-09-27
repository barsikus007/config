{ obsidian }:
obsidian.overrideAttrs (previousAttrs: {
  preInstall = (previousAttrs.preInstall or "") + ''
    # disable auto-updater and prevent loading cached/downloaded asar from userData
    asar extract resources/app.asar app-src-pre
    substituteInPlace app-src-pre/main.js \
      --replace-fail "let disable = false;" "let disable = true;" \
      --replace-fail "if (version && (isV2MoreRecent(appVersion, version) || appVersion === version))" "if (false)"
    rm --force resources/app.asar
    asar pack app-src-pre resources/app.asar
    rm --recursive --force app-src-pre

    # enable middle-click rectangular selection on linux
    asar extract resources/obsidian.asar obsidian-src
    substituteInPlace obsidian-src/app.js \
      --replace-fail "(!rd.isDesktopApp||!rd.isLinux)&&1===e.button" "1===e.button"
    rm --force resources/obsidian.asar
    asar pack obsidian-src resources/obsidian.asar
    rm --recursive --force obsidian-src
  '';
})
