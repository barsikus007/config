{
  lib,
  pkgs,
  config,
  ...
}:
let
  allFirewalls = [
    config.custom.firewall
  ]
  ++ map (u: u.custom.firewall or { }) (lib.attrValues (config.home-manager.users or { }));
in
{
  networking.networkmanager.enable = true;
  #? dns
  services.resolved.enable = true;

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
  };
  networking.nftables.enable = true;

  environment.systemPackages = with pkgs; [ nixos-firewall-tool ];

  # networking.firewall.enable = false;
  networking.firewall = {
    allowedTCPPorts = lib.pipe allFirewalls [
      (lib.concatMap (f: f.allowedTCPPorts or [ ]))
      lib.unique
    ];
    allowedUDPPorts = lib.pipe allFirewalls [
      (lib.concatMap (f: f.allowedUDPPorts or [ ]))
      lib.unique
    ];
    allowedTCPPortRanges = lib.pipe allFirewalls [
      (lib.concatMap (f: f.allowedTCPPortRanges or [ ]))
      lib.unique
    ];
    allowedUDPPortRanges = lib.pipe allFirewalls [
      (lib.concatMap (f: f.allowedUDPPortRanges or [ ]))
      lib.unique
    ];
  };
}
