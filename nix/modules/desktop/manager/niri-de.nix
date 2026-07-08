{
  pkgs,
  config,
  username,
  ...
}:
#! +1.1Gb
{
  nix.settings.extra-substituters = [ "https://noctalia.cachix.org" ];
  nix.settings.extra-trusted-public-keys = [
    "noctalia.cachix.org-1:pCOR47nnMEo5thcxNDtzWpOxNFQsBRglJzxWPp3dkU4="
  ];
  imports = [
    #! noctalia-greeter.url = "github:noctalia-dev/noctalia-greeter";
    # inputs.noctalia-greeter.nixosModules.default

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
    ../../../home/desktop/manager/quickshell/noctalia.nix
  ];

  services.displayManager.gdm.enable = !config.services.displayManager.sddm.enable;

  /*
    TODO greetd

    * fprintd
    * kwallet
    * не мыльное (kanshi?)
  */
  # programs.noctalia-greeter = {
  #   enable = true;
  #   settings = {
  #     cursor = with config.stylix.cursor; {
  #       inherit size;
  #       theme = name;
  #       path = "${package}/share/icons";
  #     };
  #   };
  # };

  #! noctalia-v5 lockscreen fprint fix
  security.pam.services.login.fprintAuth = !config.services.fprintd.enable;

  environment.systemPackages = with pkgs; [ wdisplays ];

  programs.dsearch.enable = true;
}
