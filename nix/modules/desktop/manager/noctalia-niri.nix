{
  lib,
  pkgs,
  config,
  username,
  ...
}:
#! +1.1Gb
{
  custom.persist.directories = [
    {
      # ? greeter sync with shell
      directory = "/var/lib/noctalia-greeter";
      user = "greeter";
      group = "greeter";
    }
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
    ../../../home/desktop/manager/noctalia-niri.nix
  ];

  services.displayManager.noctalia-greeter = {
    enable = true;
    cursorTheme = { inherit (config.stylix.cursor) name package; };
    settings = {
      keyboard = { inherit (config.services.xserver.xkb) layout options; };
      output.scale = 1.0;
    };
  };

  # TODO: unstable: https://github.com/noctalia-dev/noctalia-greeter/blob/d9fe1d7851464a923020d39efae8a6e3561f0d63/nix/nixos-module.nix#L165
  security.polkit.extraConfig = lib.mkAfter /* javascript */ ''
    polkit.addRule(function(action, subject) {
      var allowedUsers = ["${username}"];
      if (action.id == "org.noctalia.greeter.sync-appearance" &&
          action.lookup("program") == "${config.services.displayManager.noctalia-greeter.package}/bin/noctalia-greeter-apply-appearance" &&
          action.lookup("user") == "root" &&
          subject.local && subject.active &&
          allowedUsers.indexOf(subject.user) >= 0) {
        return polkit.Result.YES;
      }
    });
  '';

  #! noctalia-v5 lockscreen fprint fix
  security.pam.services.login.fprintAuth = !config.services.fprintd.enable;

  environment.systemPackages = with pkgs; [ wdisplays ];
}
