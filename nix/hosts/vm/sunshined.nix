{ config, username, ... }:
#? WIP: incomplete and messed as F
{
  virtualisation.vmVariant = {
    virtualisation = {
      forwardPorts =
        #? https://localhost:57990/pin
        #? localhost:57989
        let
          generatePorts = port: offsets: map (offset: port + offset) offsets;
          allowedTCPPorts = generatePorts config.services.sunshine.settings.port [
            (-5)
            0
            1
            21
          ];
          allowedUDPPorts = generatePorts config.services.sunshine.settings.port [
            9
            10
            11
            13
            21
          ];
        in
        [ ]
        ++ map (p: {
          from = "host";
          host.port = p;
          guest.port = p;
          proto = "tcp";
        }) allowedTCPPorts
        ++ map (p: {
          from = "host";
          host.port = p;
          guest.port = p;
          proto = "udp";
        }) allowedUDPPorts;
      sharedDirectories."sunshine" = {
        source = "/home/$USER/.config/sunshine/vms/${config.networking.hostName}";
        target = "/home/${username}/.config/sunshine";
      };
    };
  };
  system.activationScripts.chownConfig = {
    text = ''chown 1000:100 "/home/${username}/.config"'';
  };
  services.sunshine = {
    enable = true;
    autoStart = true;
    capSysAdmin = true;
    openFirewall = true;
    # TODO https://search.nixos.org/options?query=services.sunshine.applications
    settings.port = 57989;
  };

  hardware.uinput.enable = true;
  users.users.${username}.extraGroups = [
    "uinput"
    "input"
  ];
}
