{
  networking.networkmanager.enable = true;
  #? dns
  services.resolved.enable = true;
  networking.networkmanager.dns = "systemd-resolved";
  # networking.nameservers = [
  #   "8.8.8.8"
  #   "4.4.4.4"
  # ];
  networking.hosts = {
    "130.255.77.28" = [ "ntc.party" ];
  };

  # networking.firewall.enable = false;
  networking.firewall.allowedTCPPorts = [
    # TODO: move to home module somehow...
    12345 # ? home: rquickshare
  ];
}
