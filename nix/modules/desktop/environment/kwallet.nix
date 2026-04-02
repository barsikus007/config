{ pkgs, ... }:
{
  xdg.portal.extraPortals = with pkgs; [ kdePackages.kwallet ];
  xdg.portal.config.common."org.freedesktop.impl.portal.Secret" = [ "kwallet" ];
  #? ensure it is disabled
  services.gnome.gnome-keyring.enable = false;

  #? https://wiki.nixos.org/wiki/SSH_public_key_authentication#KDE
  #? add option to save passwords in kwallet
  environment.variables.SSH_ASKPASS_REQUIRE = "prefer";
  programs.ssh = {
    enableAskPassword = true;

    #? fallback for non-KDE
    askPassword = with pkgs; lib.getExe kdePackages.ksshaskpass;
  };
}
