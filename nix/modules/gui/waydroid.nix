{ pkgs, ... }:
{
  virtualisation.waydroid.enable = true;

  custom.persist = {
    directories = [ "/var/lib/waydroid" ];
    home.directories = [
      ".config/waydroid-helper" #? key mappings
      ".config/systemd/user/waydroid-monitor.service.d" # ? links to storage
    ];
  };

  environment.systemPackages = with pkgs; [ waydroid-helper ];

  systemd = {
    packages = with pkgs; [ waydroid-helper ];
    services.waydroid-mount.wantedBy = [ "multi-user.target" ];
  };
}
