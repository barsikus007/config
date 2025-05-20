{ inputs, ... }:
{
  imports = [
    inputs.stylix.nixosModules.stylix
    ../shared/stylix.nix
  ];
  stylix = {
    enable = true;
    # autoEnable = false;
    targets = {
      plymouth.enable = false;
    };
  };
}
