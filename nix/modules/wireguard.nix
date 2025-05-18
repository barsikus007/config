{ pkgs, username, ... }:
{
  networking.wg-quick.interfaces = {
    awg0 = {
      autostart = false;
      type = "amneziawg"; # Provided by unstable
      # TODO: secrets
      configFile = "/home/${username}/awg0.conf";
    };
  };

  environment.systemPackages = with pkgs.unstable; [
    wireguard-tools
    amneziawg-tools
  ];
}
