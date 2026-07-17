{
  replaceDependencies,
  telegram-desktop,
  telegram-desktop-client ? telegram-desktop,
  fetchFromGitHub,
  lib,
  qt6,
  ...
}:
(replaceDependencies {
  drv = telegram-desktop-client;
  replacements =
    let
      patchesRepo = fetchFromGitHub {
        #? https://github.com/desktop-app/patches/tree/7d591c8a4e38dbe58c5039473bd884d130704d97
        owner = "desktop-app";
        repo = "patches";
        rev = "7d591c8a4e38dbe58c5039473bd884d130704d97";
        hash = "sha256-RwX7UNWbq24pArNnDb1rqDf/aHCr9yN10nDf2RvXTZo=";
      };
      qtbasePatches = lib.filesystem.listFilesRecursive "${patchesRepo}/qtbase_${qt6.qtbase.version}";
      qtwaylandPatches = lib.filesystem.listFilesRecursive "${patchesRepo}/qtwayland_${qt6.qtwayland.version}";
      qtwaylandFilteredPatches = lib.filter (
        p:
        !(lib.any (excluded: lib.hasInfix excluded (baseNameOf p)) [
          "compositor-xkb-state-from-platform" # ! compilation error: 'struct QNativeInterface::QX11Application' has no member named 'xkbState'
        ])
      ) qtwaylandPatches;
    in
    [
      {
        oldDependency = qt6.qtbase;
        newDependency = qt6.qtbase.overrideAttrs (previousAttrs: {
          patches = builtins.concatLists [
            (previousAttrs.patches or [ ])
            qtbasePatches
          ];
        });
      }
    ]
    ++ lib.optional (qtwaylandFilteredPatches != [ ]) {
      oldDependency = qt6.qtwayland;
      newDependency = qt6.qtwayland.overrideAttrs (previousAttrs: {
        patches = builtins.concatLists [
          (previousAttrs.patches or [ ])
          qtwaylandFilteredPatches
        ];
      });
    };
})
