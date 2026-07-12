{
  lib,
  pkgs,
  config,
  ...
}:
{
  security.pam.services.login.kwallet.enable = true;
  security.pam.services.greetd.kwallet = lib.mkIf config.services.greetd.enable {
    enable = true;
    forceRun = true;
  };
  systemd.user.services.plasma-kwallet-pam =
    lib.mkIf (!config.services.desktopManager.plasma6.enable)
      {
        description = "Unlock kwallet from pam credentials";
        partOf = [ "graphical-session.target" ];
        wantedBy = [ "graphical-session.target" ];
        serviceConfig = {
          Type = "simple";
          #! pam forks ksecretd (a Qt GUI app) when pam_kwallet_init runs; without WAYLAND_DISPLAY in
          #! its env it cannot connect to a display and SIGABRTs, leaving the wallet locked. niri
          #! creates the wayland socket BEFORE exporting WAYLAND_DISPLAY into the systemd user env, so
          #! waiting on the socket is not enough -- wait for the env var itself, put it in our env, then
          #! run pam_kwallet_init (which forwards the env onward to the forked ksecretd)
          ExecStart = pkgs.writeShellScript "kwallet-pam-unlock" /* bashh */ ''
            for _ in $(seq 1 300); do
              wd=$(${lib.getExe' pkgs.systemd "systemctl"} --user show-environment | sed -n 's/^WAYLAND_DISPLAY=//p')
              if [ -n "$wd" ]; then
                export WAYLAND_DISPLAY="$wd"
                break
              fi
              sleep 0.1
            done
            exec ${pkgs.kdePackages.kwallet-pam}/libexec/pam_kwallet_init
          '';
          Slice = "background.slice";
          Restart = "no";
        };
      };
  xdg.portal.extraPortals = with pkgs; [ kdePackages.kwallet ];
  xdg.portal.config.common."org.freedesktop.impl.portal.Secret" = [ "kwallet" ];
  #? ensure it is disabled
  services.gnome.gnome-keyring.enable = false;

  environment.systemPackages = with pkgs; [
    kdePackages.kwalletmanager
    libsecret
  ];

  #? https://wiki.nixos.org/wiki/SSH_public_key_authentication#KDE
  #? add option to save passwords in kwallet
  environment.variables.SSH_ASKPASS_REQUIRE = "prefer";
  programs.ssh = {
    enableAskPassword = true;

    #? fallback for non-KDE
    askPassword = with pkgs; lib.getExe kdePackages.ksshaskpass;
  };
}
