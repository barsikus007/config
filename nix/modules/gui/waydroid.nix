{ pkgs, ... }:
{
  virtualisation.waydroid.enable = true;

  environment.systemPackages = with pkgs; [ waydroid-helper ];

  systemd = {
    packages = with pkgs; [ waydroid-helper ];
    services.waydroid-mount.wantedBy = [ "multi-user.target" ];
  };
}
