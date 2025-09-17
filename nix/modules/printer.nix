{ pkgs, ... }:
{
  services.printing = {
    enable = true;
    drivers = [
      (pkgs.callPackage ../packages/mprint.nix { })
    ];
  };
}
