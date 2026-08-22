{
  lib,
  pkgs,
  config,
  username,
  ...
}:
let
  hmConfig = config.home-manager.users.${username};
in
{
  # TODO: claim /etc/NetworkManager/system-connections from the host persist list
  networking.networkmanager.enable = true;
  #? dns
  services.resolved.enable = true;
  # networking.nameservers = [
  #   "1.1.1.1"
  #   "9.9.9.9"
  #   "8.8.8.8"
  # ];

  #? nsncd worker starvation during resume: hostname lookups hang in dead-tunnel DNS
  #? and exhaust the 8 default workers, so unrelated passwd/group lookups (polkit ->
  #? logind Inhibit) wait out the handoff. 64 workers keep local lookups instant
  #? even when the resolver is unreachable. The unit is nscd.service
  #? (services.nscd.enableNsncd just swaps the binary); a systemd.services.nsncd key
  #? would silently create a phantom unit.
  #! do not put NSNCD_HANDOFF_TIMEOUT here: nixpkgs pins it to 10 via
  #! serviceConfig.Environment, which systemd renders after this attrset and wins
  #! it is also not a per-request timeout, on expiry nsncd leaves the accept loop
  #! and exits, so it must stay above the time clients need to fall back to libc
  systemd.services.nscd.environment = {
    NSNCD_WORKER_COUNT = "64";
  };
  networking.hosts = {
    "130.255.77.28" = [ "ntc.party" ];
    "95.182.120.241" = [
      "chatgpt.com"

      "videos.openai.com"

      #! pendos geo
      "sora.com"
      "sora.chatgpt.com"
    ];
  };
  networking.nftables.enable = true;

  environment.systemPackages = with pkgs; [ nixos-firewall-tool ];

  # networking.firewall.enable = false;
  # TODO: unified custom config: firewall: rquickshare,syncthing
  networking.firewall = {
    allowedTCPPorts = builtins.concatLists [
      (lib.optionals (lib.any (pkg: lib.getName pkg == "rquickshare") hmConfig.home.packages) [ 12345 ])
      (lib.optionals hmConfig.services.syncthing.enable [ 22000 ])
    ];
    allowedUDPPorts = builtins.concatLists [
      (lib.optionals hmConfig.services.syncthing.enable [
        21027
        22000
      ])
    ];
  };
}
