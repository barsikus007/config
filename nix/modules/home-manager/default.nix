{ config, specialArgs, ... }:
{
  #? `custom` is declared on the host, mirror it into every home
  home-manager.sharedModules = [ { inherit (config) custom; } ];
  home-manager.useGlobalPkgs = true;
  home-manager.useUserPackages = true;
  home-manager.extraSpecialArgs = specialArgs;
  home-manager.backupFileExtension = "hmbackup";
  #? fd --hidden hmbackup ~
  #? fd --hidden hmbackup ~ --exec-batch rm --
}
