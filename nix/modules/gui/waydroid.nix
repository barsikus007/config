{ pkgs, ... }:
{
  virtualisation.waydroid.enable = true;

  environment.systemPackages = [ pkgs.unstable.waydroid-helper ];

  systemd = {
    packages = [ pkgs.unstable.waydroid-helper ];
    services.waydroid-mount.wantedBy = [ "multi-user.target" ];
  };
}
