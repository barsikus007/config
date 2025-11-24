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
        # https://github.com/desktop-app/patches/tree/0b68b11048987a68d31b2d8380d9b7c5116aa961
        owner = "desktop-app";
        repo = "patches";
        rev = "0b68b11048987a68d31b2d8380d9b7c5116aa961";
        hash = "sha256-eSIO7ALsC8W4bR/KOk7kgDMd9/ABNN8EdCiJwVAK24g=";
      };
      qtbasePatches = lib.filesystem.listFilesRecursive "${patchesRepo}/qtbase_6.10.0";
      qtwaylandPatches = lib.filesystem.listFilesRecursive "${patchesRepo}/qtwayland_6.10.0";
    in
    [
      {
        oldDependency = qt6.qtbase;
        newDependency = qt6.qtbase.overrideAttrs (oldAttrs: {
          patches = (oldAttrs.patches or [ ]) ++ qtbasePatches;
        });
      }
      {
        oldDependency = qt6.qtwayland;
        newDependency = qt6.qtwayland.overrideAttrs (oldAttrs: {
          patches =
            (oldAttrs.patches or [ ])
            ++ [ (builtins.elemAt qtwaylandPatches 0) ]
            ++ [ (builtins.elemAt qtwaylandPatches 1) ]
            # ++ [ (builtins.elemAt qtwaylandPatches 2) ] # compilation error
            ++ [ ];
        });
      }
    ];
})
