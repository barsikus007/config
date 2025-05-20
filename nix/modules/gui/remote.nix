{ pkgs, ... }:
{
  # rdp
  # networking.firewall.allowedTCPPorts = [ 3389 ];
  # networking.firewall.allowedUDPPorts = [ 3389 ];

  services.rustdesk-server = {
    enable = true;
    openFirewall = true;
    signal.relayHosts = [ "rs-sg.rustdesk.com" ];
  };
  services.sunshine = {
    enable = true;
    autoStart = true;
    capSysAdmin = true; # only needed for Wayland -- omit this when using with Xorg
    openFirewall = true;
    # TODO https://search.nixos.org/options?query=services.sunshine.applications
  };

  environment.defaultPackages = with pkgs; [
    rustdesk-flutter
  ];
}
