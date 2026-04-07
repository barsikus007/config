{ pkgs, username, ... }:
{
  networking.wg-quick.interfaces = {
    awg0 = {
      autostart = false;
      type = "amneziawg";
      # TODO: secrets
      configFile = "/home/${username}/awg0.conf";
    };
    wg0local = {
      autostart = false;
      # type = "amneziawg";
      # TODO: secrets
      configFile = "/home/${username}/wg0local.conf";
    };
  };

  environment.systemPackages = with pkgs; [
    wireguard-tools
    amneziawg-tools
  ];
}
