{ username, ... }:
#! +?Gb
{
  #! add this to flake inputs
  #? dms = { url = "github:AvengeMedia/DankMaterialShell/stable"; inputs.nixpkgs.follows = "nixpkgs"; };
  imports = [
    ./niri.nix
    ../../hardware/ddcutil.nix
    ../style/uniform-look.nix
    ../environment/explorer/dolphin.nix
    ../environment/kde-dbus.nix
    ../environment/kdeconnect.nix
    ../environment/kwallet.nix
    ../environment/win-apps.nix
  ];
  home-manager.users.${username}.imports = [
    ../../../home/desktop/environment/kde-settings.nix
    ../../../home/desktop/environment/kde-stylix.nix
    ../../../home/desktop/manager/quickshell/dms.nix
  ];

  services.displayManager.dms-greeter = {
    enable = true;
    configHome = "/home/${username}";
  };

  programs.dsearch.enable = true;
}
