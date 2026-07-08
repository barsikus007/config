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

  #! vibecoded shitfix for fprint pam
  #? noctalia auths via a system PAM service (default `login`, but GDM force-strips fprintd from it and noctalia dropped its self-carried pam in migration 46), so give it a dedicated one and point NOCTALIA_PAM_SERVICE at it; fingerprint only when fprintd is on, password stays as fallback
  security.pam.services.noctalia.fprintAuth = config.services.fprintd.enable;
  environment.sessionVariables.NOCTALIA_PAM_SERVICE = "noctalia";

  #? noctalia's screenUnlock hook restarts fprintd to clear the goodix phantom claim left by allowPasswordWithFprintd; allow just that unit without a password
  security.polkit.extraConfig = /* javascript */ ''
    polkit.addRule(function (action, subject) {
      if (action.id === "org.freedesktop.systemd1.manage-units"
        && action.lookup("unit") === "fprintd.service"
        && subject.user === "${username}") {
        return polkit.Result.YES;
      }
    });
  '';

  environment.systemPackages = with pkgs; [ wdisplays ];

  programs.dsearch.enable = true;
}
