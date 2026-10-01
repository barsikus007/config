{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  copyDesktopItems,
  elfutils,
  libx11,
  makeDesktopItem,
  ninja,
  pkg-config,
  qt6,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "taskexplorer";
  version = "2.0.0";

  src = fetchFromGitHub {
    owner = "DavidXanatos";
    repo = "TaskExplorer";
    tag = "v${finalAttrs.version}";
    hash = "sha256-9cO8Nx7hy1NhrhIyoTBoX6nMtszEnpf2FSuVfYdOpmA=";
  };

  nativeBuildInputs = [
    cmake
    ninja
    pkg-config
    qt6.wrapQtAppsHook
    qt6.qttools
    copyDesktopItems
  ];

  buildInputs = [
    qt6.qtbase
    qt6.qtsvg
    elfutils
    libx11
  ];

  cmakeFlags = [
    "-DTE_BUNDLE_QT=OFF"
    "-DCMAKE_BUILD_WITH_INSTALL_RPATH=ON"
    "-DCMAKE_INSTALL_RPATH=${placeholder "out"}/lib"
  ];

  installPhase = ''
    runHook preInstall

    for d in Bin/linux-* ../Bin/linux-*; do
      [ -d "$d" ] && binDir="$d" && break
    done

    install -Dm755 "$binDir/TaskExplorer" "$out/bin/TaskExplorer"
    install -Dm755 "$binDir/TaskHelper" "$out/bin/TaskHelper"
    install -Dm755 "$binDir/libTaskCore.so" "$out/lib/libTaskCore.so"

    # loose runtime data expected next to the executable
    if [ -d "$binDir/translations" ]; then
      cp --recursive "$binDir/translations" "$out/bin/"
    fi
    if [ -d "$binDir/DistroLogos" ]; then
      cp --recursive "$binDir/DistroLogos" "$out/bin/"
    fi

    # desktop icons
    install -Dm644 ../TaskExplorer/Resources/exe16.png "$out/share/icons/hicolor/16x16/apps/TaskExplorer.png"
    install -Dm644 ../TaskExplorer/Resources/exe32.png "$out/share/icons/hicolor/32x32/apps/TaskExplorer.png"
    install -Dm644 ../TaskExplorer/Resources/exe48.png "$out/share/icons/hicolor/48x48/apps/TaskExplorer.png"
    install -Dm644 ../TaskExplorer/Resources/exe64.png "$out/share/icons/hicolor/64x64/apps/TaskExplorer.png"

    runHook postInstall
  '';

  desktopItems = [
    (makeDesktopItem {
      name = "TaskExplorer";
      categories = [
        "System"
        "Monitor"
      ];
      comment = "Advanced task manager and process explorer";
      desktopName = "Task Explorer";
      exec = "TaskExplorer";
      icon = "TaskExplorer";
      keywords = [
        "task"
        "manager"
        "process"
        "explorer"
        "systeminformer"
      ];
    })
  ];

  meta = {
    description = "Advanced task manager and process explorer for Linux and Windows";
    homepage = "https://github.com/DavidXanatos/TaskExplorer";
    license = lib.licenses.gpl3Only;
    maintainers = [ ];
    platforms = lib.platforms.linux;
    mainProgram = "TaskExplorer";
  };
})
