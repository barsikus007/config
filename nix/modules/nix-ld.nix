{ pkgs, ... }:
#? https://wiki.nixos.org/wiki/Nix-ld
#? https://unix.stackexchange.com/a/522823
{
  programs.nix-ld.enable = true;
  programs.nix-ld.libraries =
    let
      closureRoots =
        with pkgs;
        builtins.concatLists [
          #? nix-locate lib/libgobject-2.0.so.0
          [
            nss
            # fuse3
            # vulkan-headers
            # vulkan-tools

            #? libQt6PrintSupport for cheat-engine
            kdePackages.qtbase
          ]
          (steam-run.args.targetPkgs pkgs)
          (steam-run.args.multiPkgs pkgs)
        ];
    in
    [
      (pkgs.buildEnv {
        name = "nix-ld-closure-libs";
        paths = closureRoots;
        pathsToLink = [ "/lib" ];
        includeClosures = true;
        ignoreCollisions = true;
      })
    ];
}
