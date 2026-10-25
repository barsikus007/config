{ lib, pkgs, ... }@args:
let
  inInterface = args.inInterface or "awg0";
  # inInterfaceFolder = "/etc/wireguard";
  inInterfaceFolder = "/etc/amnezia/amneziawg";
  inInterfaceCfg =
    args.inInterfaceCfg or {
      type = "amneziawg";
      configFile = "${inInterfaceFolder}/${inInterface}.conf";
    };
  inInterfacePort = args.inInterfacePort or 51820;
in
{
  custom.persist.directories = lib.optional (
    (inInterfaceCfg ? configFile) && (inInterfaceCfg.configFile != null)
  ) (dirOf (toString inInterfaceCfg.configFile));

  environment.systemPackages = with pkgs; [
    wireguard-tools
    amneziawg-tools
  ];

  networking.nat = {
    #? https://docs.kernel.org/networking/ip-sysctl.html
    #! this also set sysctl `net.ipv4.conf.all.forwarding` to 1 which sets `net.ipv4.ip_forward` to 1
    enable = true;
    internalInterfaces = [ inInterface ];
    #! `externalInterface` are unset due to possible multihop setup
  };
  networking.firewall.allowedUDPPorts = [ inInterfacePort ];
  networking.wg-quick.interfaces.${inInterface} = inInterfaceCfg;
  #? avoid failing boot if config file is not synced yet
  systemd.services."wg-quick-${inInterface}" = lib.mkIf (inInterfaceCfg ? configFile) {
    unitConfig.ConditionPathExists = inInterfaceCfg.configFile;
  };
}
