{
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
    #? to compile completions at NixOS buildtime
    ../../shared/zsh-compinit.nix
  ];
  home-manager.users.${username}.imports = [
    ../../home
    ../../home/shell/minimal.nix
    { home.stateVersion = "26.05"; }
  ];
  environment.systemPackages = import ../../shared/lists { inherit pkgs; };

  services.openssh.settings.PermitRootLogin = "yes";
  users.users.root.openssh.authorizedKeys.keys =
    config.users.users.${username}.openssh.authorizedKeys.keys;
}
