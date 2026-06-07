{
  lib,
  pkgs,
  config,
  ...
}:
let
  cfg = config.services.wireguard-ui;
  configFile = "${cfg.configDir}/${cfg.interface}.conf";
  reloadTool = lib.getExe cfg.tools;
in
{
  options.services.wireguard-ui = {
    enable = lib.mkEnableOption "wireguard-ui";

    package = lib.mkOption {
      type = lib.types.package;
      default = pkgs.wireguard-ui;
      defaultText = lib.literalExpression "pkgs.wireguard-ui";
      description = "Package to use for wireguard-ui";
    };

    tools = lib.mkOption {
      type = lib.types.package;
      default = pkgs.wireguard-tools;
      defaultText = lib.literalExpression "pkgs.wireguard-tools";
      description = "Package providing wg/wg-quick used by the in-place reloader";
    };

    address = lib.mkOption {
      type = lib.types.str;
      default = "0.0.0.0";
      description = "Address on which the web UI listens";
    };

    port = lib.mkOption {
      type = lib.types.port;
      default = 5000;
      description = "Port on which the web UI listens";
    };

    interface = lib.mkOption {
      type = lib.types.str;
      default = "wg0";
      description = "WireGuard interface the UI manages";
    };

    configDir = lib.mkOption {
      type = lib.types.path;
      default = "/etc/wireguard";
      description = "Directory holding the interface config and peers";
    };

    environment = lib.mkOption {
      type = lib.types.attrsOf lib.types.str;
      default = { };
      example = lib.literalExpression ''{ WGUI_MTU = "1420"; }'';
      description = "Extra WGUI_* environment variables passed to the service";
    };

    openFirewall = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Whether to open the firewall for the web UI";
    };
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [ cfg.package ];

    systemd.services.wireguard-ui = {
      description = "WireGuard UI web interface";
      wantedBy = [ "multi-user.target" ];
      after = [ "network.target" ];
      path = [
        cfg.tools
        pkgs.systemd
      ];
      environment = {
        # https://github.com/ngoduykhanh/wireguard-ui/pull/660
        WGUI_MTU = "1420";
        WGUI_CONFIG_FILE_PATH = configFile;
      }
      // cfg.environment;
      serviceConfig = {
        ExecStart = "${lib.getExe cfg.package} --bind-address ${cfg.address}:${toString cfg.port}";
        WorkingDirectory = "/var/lib/wireguard-ui";
        StateDirectory = "wireguard-ui";
        Restart = "always";
      };
    };

    # https://github.com/ngoduykhanh/wireguard-ui#using-systemd
    systemd.paths.wireguard-ui-watcher = {
      description = "Watch ${configFile} for changes";
      wantedBy = [ "multi-user.target" ];
      pathConfig.PathModified = configFile;
    };
    systemd.services.wireguard-ui-watcher = {
      description = "Reload WireGuard interface ${cfg.interface}";
      after = [ "network.target" ];
      requiredBy = [ "wireguard-ui-watcher.path" ];
      path = [ cfg.tools ];
      script = "${reloadTool} syncconf ${cfg.interface} <(${reloadTool}-quick strip ${cfg.interface})";
      serviceConfig.Type = "oneshot";
    };

    systemd.tmpfiles.rules = [
      "d ${cfg.configDir} 0700 root root -"
    ];

    networking.firewall.allowedTCPPorts = lib.mkIf cfg.openFirewall [ cfg.port ];
  };
}
