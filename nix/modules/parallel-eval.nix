{ lib, inputs, ... }:
#? https://determinate.systems/blog/changelog-determinate-nix-3111/
{
  #! add this to flake inputs
  #? determinate.url = "https://flakehub.com/f/DeterminateSystems/determinate/*";
  imports = [
    inputs.determinate.nixosModules.default
  ];
  nix.settings.experimental-features = [ "parallel-eval" ];
  nix.settings.substituters = lib.mkAfter [ "https://install.determinate.systems" ];
  nix.settings.trusted-public-keys = lib.mkAfter [
    "cache.flakehub.com-3:hJuILl5sVK4iKm86JzgdXW12Y2Hwd5G07qKtHTOcDCM="
  ];
}
