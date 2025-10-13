{ pkgs, ... }:
{
  virtualisation.waydroid.enable = true;

  environment.systemPackages = [ pkgs.waydroid-helper ];

  systemd = {
    packages = [ pkgs.unstable.waydroid-helper ];
    services.waydroid-mount.wantedBy = [ "multi-user.target" ];
  };
}
