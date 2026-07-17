{ inputs, specialArgs, ... }:
{
  imports = [
    inputs.home-manager.nixosModules.home-manager
  ];
  home-manager.useGlobalPkgs = true;
  home-manager.useUserPackages = true;
  home-manager.extraSpecialArgs = specialArgs;
  home-manager.backupFileExtension = "hmbackup";
  #? fd --hidden hmbackup ~
  #? fd --hidden hmbackup ~ | xargs rm
}
