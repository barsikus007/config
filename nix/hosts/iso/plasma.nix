{ lib, modulesPath, ... }:
#? default graphical, but without gnome
{
  imports = [
    ./.
  ];
  isoImage.edition = "graphical";
  isoImage.showConfiguration = lib.mkDefault false;

  specialisation = {
    #? https://github.com/NixOS/nixpkgs/blob/fb9c69c7033731e7d3f713d9cc209065b8ad7f02/nixos/modules/installer/cd-dvd/installation-cd-graphical-combined.nix#L33
    plasma.configuration = {
      imports = [ (modulesPath + "/installer/cd-dvd/installation-cd-graphical-calamares-plasma6.nix") ];
      isoImage.showConfiguration = true;
      isoImage.configurationName = "Plasma (Linux LTS)";
    };
    plasma_latest_kernel.configuration =
      { config, ... }:
      {
        imports = [
          (modulesPath + "/installer/cd-dvd/installation-cd-graphical-calamares-plasma6.nix")
          (modulesPath + "/installer/cd-dvd/latest-kernel.nix")
        ];
        isoImage.showConfiguration = true;
        isoImage.configurationName = "Plasma (Linux ${config.boot.kernelPackages.kernel.version})";
      };
  };
}
