{ inputs, ... }:
#? https://codeberg.org/wvhulle/bootvine/src/branch/main/docs/install.md
{
  imports = [
    inputs.bootvine.nixosModules.default
  ];

  services.bootvine.enable = true;
  #? to open the bootloader list, press any key
  boot.loader.timeout = 0;
}
