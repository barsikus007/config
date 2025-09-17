{
  #? dns
  services.resolved.enable = true;
  networking.networkmanager.dns = "systemd-resolved";
  networking.hosts = {
    "130.255.77.28" = [ "ntc.party" ];
  };

  # networking.firewall.enable = false;
}
