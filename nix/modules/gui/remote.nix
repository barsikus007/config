{ pkgs, username, ... }:
{
  #? rdp
  # networking.firewall.allowedTCPPorts = [ 3389 ];
  # networking.firewall.allowedUDPPorts = [ 3389 ];

  services.rustdesk-server = {
    enable = true;
    openFirewall = true;
    signal.relayHosts = [ "rs-sg.rustdesk.com" ];
  };
  environment.systemPackages = with pkgs; [ rustdesk-flutter ];

  services.sunshine = {
    enable = true;
    autoStart = true;
    capSysAdmin = true; # ? needed for running on Wayland
    openFirewall = true;
  };
  #! sunshine.service WantedBy = graphical-session.target fix
  systemd.user.services.sunshine.unitConfig.ConditionUser = username;
  programs.moonlight-qt = {
    enable = true;
    capSysNice = true;
  };
}
