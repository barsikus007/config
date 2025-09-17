{
  #? dns
  services.resolved.enable = true;
  networking.networkmanager.dns = "systemd-resolved";

  # networking.firewall.enable = false;
}
