{ lib, username, ... }:
#! 30Mb
{
  imports = [
    ../modules/ssh-secure.nix
    #! 150Kb
    ../shared/nix.nix
    ../modules/home-manager.nix
    #! 17Mb
    ../shared/nh.nix
  ];

  #? https://nixos.org/manual/nixos/unstable/release-notes
  system.stateVersion = lib.mkDefault "26.05";

  hardware.ksm.enable = true;

  i18n.defaultLocale = "C.UTF-8";
  #? ISO time
  i18n.extraLocaleSettings.LC_TIME = lib.mkDefault "en_DK.UTF-8";
  console.font = "LatArCyrHeb-16";
  services.xserver.xkb = {
    layout = "us,ru";
    options = "grp:win_space_toggle,grp:caps_toggle";
  };
  #! https://github.com/NixOS/nixpkgs/issues/529189
  console.useXkbConfig = true;

  #? Don't forget to set a password with ‘passwd’.
  users.users.${username} = {
    isNormalUser = true;
    uid = 1000;
    extraGroups = [ "wheel" ];
  };
  nix.settings.trusted-users = [ username ];

  #! 80Kb
  programs.nix-ld.enable = true;
}
