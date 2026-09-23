{
  lib,
  pkgs,
  config,
  username,
  ...
}:
#? https://wiki.nixos.org/wiki/Creating_a_NixOS_live_CD
{
  imports = [
    ../.
    ../../modules/copy-flake.nix
    ../../modules/home-manager/simple.nix
    #? to compile completions at NixOS buildtime
    ../../shared/zsh-compinit.nix
  ];
  environment.systemPackages = import ../../shared/lists { inherit pkgs; };

  system.stateVersion = config.system.nixos.release;

  users.defaultUserShell = lib.mkForce pkgs.bashInteractive;

  services.openssh.settings.PermitRootLogin = "yes";
  users.users.root.openssh.authorizedKeys.keys =
    config.users.users.${username}.openssh.authorizedKeys.keys;
}
