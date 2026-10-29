{
  lib,
  pkgs,
  config,
  ...
}:
let
  cfg = config.services.wireguard-server;
in
{
  options.services.wireguard-server = {
    clientInterfaces = lib.mkOption {
      type = lib.types.attrsOf (
        lib.types.submodule (
          { config, name, ... }:
          let
            folder = if config.type == "wireguard" then "/etc/wireguard" else "/etc/amnezia/amneziawg";
          in
          {
            options = {
              port = lib.mkOption {
                type = lib.types.port;
                default = 51820;
                description = "wireguard UDP listen port";
              };

              type = lib.mkOption {
                type = lib.types.enum [
                  "wireguard"
                  "amneziawg"
                ];
                default = "amneziawg";
                description = "wireguard interface type";
              };

              configFile = lib.mkOption {
                type = lib.types.nullOr lib.types.str;
                default = "${folder}/${name}.conf";
                description = "path to wireguard configuration file";
              };
            };
          }
        )
      );
      default = {
        awg0 = { };
      };
      description = "client-facing VPN interfaces (ingress)";
    };
  };

  config =
    let
      types = map (iface: iface.type) (builtins.attrValues config.networking.wg-quick.interfaces);
      hasAmnezia = lib.elem "amneziawg" types;
      hasWireguard = lib.elem "wireguard" types;
    in
    {
      custom.persist.directories = lib.pipe cfg.clientInterfaces [
        builtins.attrValues
        (map (iface: if iface.configFile != null then dirOf (toString iface.configFile) else null))
        (lib.filter (d: d != null))
        lib.unique
      ];

      environment.systemPackages =
        lib.optional hasWireguard pkgs.wireguard-tools ++ lib.optional hasAmnezia pkgs.amneziawg-tools;

      networking.nat = {
        #? https://docs.kernel.org/networking/ip-sysctl.html
        #! this also set sysctl `net.ipv4.conf.all.forwarding` to 1 which sets `net.ipv4.ip_forward` to 1
        enable = true;
        internalInterfaces = builtins.attrNames cfg.clientInterfaces;
        #! `externalInterface` are unset due to possible multihop setup
      };

      networking.firewall.allowedUDPPorts = lib.pipe cfg.clientInterfaces [
        builtins.attrValues
        (map (iface: iface.port))
        lib.unique
      ];

      networking.wg-quick.interfaces = lib.mapAttrs (_: iface: {
        type = lib.mkDefault iface.type;
        configFile = lib.mkIf (iface.configFile != null) (lib.mkDefault iface.configFile);
        listenPort = lib.mkDefault iface.port;
      }) cfg.clientInterfaces;

      #? avoid failing boot if config file is not synced yet
      systemd.services = lib.mapAttrs' (name: iface: {
        name = "wg-quick-${name}";
        value = lib.mkIf (iface.configFile != null) {
          unitConfig.ConditionPathExists = iface.configFile;
        };
      }) cfg.clientInterfaces;
    };
}
