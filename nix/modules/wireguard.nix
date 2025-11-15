{ pkgs, username, ... }:
{
  networking.wg-quick.interfaces = {
    awg0 = {
      autostart = false;
      type = "amneziawg";
      # TODO: secrets
      configFile = "/home/${username}/awg0.conf";
    };
  };

  environment.systemPackages = with pkgs; [
    wireguard-tools
    amneziawg-tools
  ];
}
