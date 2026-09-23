{
  lib,
  pkgs,
  self,
  config,
  ...
}:
let
  cfg = config.services.free-turn-proxy;

  obfProfiles = [
    "none"
    "rtpopus"
    "rtpopus2"
    "rtpopus3"
  ];

  #? -obf-key has no env fallback upstream, so read the secret at start time
  mkExec =
    {
      binary,
      flags,
      obfKeyFile,
    }:
    let
      args = lib.escapeShellArgs flags;
    in
    if obfKeyFile == null then
      "${cfg.package}/bin/${binary} ${args}"
    else
      pkgs.writeShellScript "${binary}-start" ''
        exec ${cfg.package}/bin/${binary} ${args} -obf-key "$(cat "$CREDENTIALS_DIRECTORY/obf-key")"
      '';

  commonFlags =
    c:
    [
      "-mode"
      c.mode
      "-obf-profile"
      c.obfProfile
    ]
    ++ lib.optionals (c.obfTiming != null) [
      "-obf-timing"
      c.obfTiming
    ]
    ++ lib.optional c.debug "-debug"
    ++ c.extraFlags;

  mkService =
    {
      binary,
      c,
      description,
      flags,
      hardening,
      name,
      environment ? { },
    }:
    lib.mkIf c.enable {
      inherit description environment;
      wantedBy = [ "multi-user.target" ];
      after = [ "network-online.target" ];
      wants = [ "network-online.target" ];
      serviceConfig = {
        ExecStart = mkExec {
          inherit binary flags;
          inherit (c) obfKeyFile;
        };
        LoadCredential = lib.optional (c.obfKeyFile != null) "obf-key:${c.obfKeyFile}";
        Restart = "always";
        RestartSec = 5;
        StateDirectory = name;
        WorkingDirectory = "/var/lib/${name}";
      }
      // hardening;
    };

  hardeningCommon = {
    AmbientCapabilities = [ "" ];
    CapabilityBoundingSet = [ "" ];
    #? implies NoNewPrivileges, RestrictSUIDSGID, and ProtectSystem=strict
    DynamicUser = true;
    LockPersonality = true;
    MemoryDenyWriteExecute = true;
    PrivateDevices = true;
    PrivateTmp = true;
    ProtectClock = true;
    ProtectControlGroups = true;
    ProtectHome = true;
    ProtectHostname = true;
    ProtectKernelLogs = true;
    ProtectKernelModules = true;
    ProtectKernelTunables = true;
    ProtectProc = "invisible";
    RestrictAddressFamilies = [
      "AF_INET"
      "AF_INET6"
      "AF_UNIX"
    ];
    RestrictNamespaces = true;
    RestrictRealtime = true;
    SystemCallArchitectures = "native";
    SystemCallErrorNumber = "EPERM";
    SystemCallFilter = [
      "@system-service"
      "~@privileged"
      "~@resources"
    ];
    UMask = "0077";
  };

  sharedOptions = {
    enable = lib.mkEnableOption "";

    mode = lib.mkOption {
      type = lib.types.enum [
        "udp"
        "tcp"
      ];
      default = "udp";
      description = "Tunnel mode: udp for WireGuard, tcp for Xray/sing-box";
    };

    obfProfile = lib.mkOption {
      type = lib.types.enum obfProfiles;
      default = "rtpopus";
      description = "Payload obfuscation wire profile, must match the other side";
    };

    obfKeyFile = lib.mkOption {
      type = lib.types.nullOr lib.types.path;
      default = null;
      example = "/run/secrets/free-turn-proxy/obf-key";
      description = ''
        File with the 64 hex char shared key, required when obfProfile is not none
        Generate with `free-turn-proxy-server -gen-obf-key`
      '';
    };

    obfTiming = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      example = "20ms";
      description = "Inter packet delay for RTP mimicry, only with obfProfile != none and mode udp";
    };

    debug = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable debug logs";
    };

    extraFlags = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      example = [
        "-platform"
        "mobile"
      ];
      description = "Extra flags appended to the command line";
    };
  };
in
{
  options.services.free-turn-proxy = {
    package = lib.mkOption {
      type = lib.types.package;
      default = self.packages.${pkgs.stdenv.hostPlatform.system}.free-turn-proxy;
      defaultText = lib.literalExpression "self.packages.\${system}.free-turn-proxy";
      description = "Package providing the client and server binaries";
    };

    server = sharedOptions // {
      enable = lib.mkEnableOption "free-turn-proxy server (VPS side)";

      listen = lib.mkOption {
        type = lib.types.str;
        default = "0.0.0.0:56000";
        description = "Public listen address ip:port, always UDP on the wire";
      };

      connect = lib.mkOption {
        type = lib.types.str;
        example = "127.0.0.1:51820";
        description = "Local backend host:port, WireGuard or Xray";
      };

      clientsFile = lib.mkOption {
        type = lib.types.nullOr lib.types.path;
        default = null;
        example = "/var/lib/free-turn-proxy/clients.json";
        description = "JSON allowlist path, enables Client ID authorization when set";
      };

      openFirewall = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Whether to open the UDP listen port";
      };
    };

    client = sharedOptions // {
      enable = lib.mkEnableOption "free-turn-proxy client";

      listen = lib.mkOption {
        type = lib.types.str;
        default = "127.0.0.1:9000";
        description = "Local address the WireGuard or Xray client connects to";
      };

      peer = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        default = null;
        example = "1.2.3.4:56000";
        description = "Server address on the VPS, host:port";
      };

      dnsMode = lib.mkOption {
        type = lib.types.enum [
          "auto"
          "plain"
          "doh"
        ];
        default = "auto";
        description = "Resolver mode: auto, plain, or doh";
      };

      dnsServers = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [ ];
        example = [ "1.1.1.1:53" ];
        description = "Custom DNS servers";
      };

      subUrl = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        default = null;
        example = "https://example.com/sub.md";
        description = ''
          Subscription URL for server list
          Format: https://github.com/samosvalishe/free-turn-proxy/blob/master/docs/sub.md
        '';
      };

      links = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [ ];
        example = [ "https://vk.ru/call/join/AAA" ];
        description = "VK Calls links used as TURN creds source, required for provider vk";
      };

      provider = lib.mkOption {
        type = lib.types.str;
        default = "vk";
        description = "TURN creds source";
      };

      streams = lib.mkOption {
        type = lib.types.ints.positive;
        default = 10;
        description = "Number of parallel TURN streams (-n)";
      };

      transport = lib.mkOption {
        type = lib.types.enum [
          "tcp"
          "udp"
        ];
        default = "tcp";
        description = "Transport to the TURN relay";
      };

      clientId = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        default = null;
        description = "Client ID checked against the server allowlist, autogenerated when null";
      };
    };
  };

  config = lib.mkIf (cfg.server.enable || cfg.client.enable) {
    assertions = [
      {
        assertion =
          !cfg.server.enable || (cfg.server.obfProfile == "none") == (cfg.server.obfKeyFile == null);
        message = "services.free-turn-proxy.server: obfKeyFile is required with obfProfile != none and unused with none";
      }
      {
        assertion =
          !cfg.client.enable || (cfg.client.obfProfile == "none") == (cfg.client.obfKeyFile == null);
        message = "services.free-turn-proxy.client: obfKeyFile is required with obfProfile != none and unused with none";
      }
      {
        assertion = !cfg.client.enable || cfg.client.peer != null || cfg.client.subUrl != null;
        message = "services.free-turn-proxy.client: peer is required when subUrl is null";
      }
      {
        assertion =
          !cfg.client.enable
          || cfg.client.subUrl != null
          || cfg.client.provider != "vk"
          || cfg.client.links != [ ];
        message = "services.free-turn-proxy.client: links is required with provider vk";
      }
    ];

    environment.systemPackages = [ cfg.package ];

    systemd.services.free-turn-proxy-server =
      let
        listenPort = lib.toInt (lib.last (lib.splitString ":" cfg.server.listen));
        isLowPort = listenPort < 1024;
      in
      mkService {
        name = "free-turn-proxy-server";
        description = "Free TURN Proxy server";
        c = cfg.server;
        binary = "free-turn-proxy-server";
        flags = [
          "-listen"
          cfg.server.listen
          "-connect"
          cfg.server.connect
        ]
        ++ lib.optionals (cfg.server.clientsFile != null) [
          "-clients-file"
          (toString cfg.server.clientsFile)
        ]
        ++ commonFlags cfg.server;
        hardening =
          hardeningCommon
          // lib.optionalAttrs isLowPort {
            AmbientCapabilities = [ "CAP_NET_BIND_SERVICE" ];
            CapabilityBoundingSet = [ "CAP_NET_BIND_SERVICE" ];
          };
        environment = lib.optionalAttrs (cfg.server.clientsFile != null) {
          CLIENTS_FILE = toString cfg.server.clientsFile;
        };
      };

    systemd.services.free-turn-proxy-client = mkService {
      name = "free-turn-proxy-client";
      description = "Free TURN Proxy client";
      c = cfg.client;
      binary = "free-turn-proxy-client";
      flags = [
        "-listen"
        cfg.client.listen
        "-provider"
        cfg.client.provider
        "-transport"
        cfg.client.transport
        "-n"
        (toString cfg.client.streams)
      ]
      ++ lib.optionals (cfg.client.peer != null) [
        "-peer"
        cfg.client.peer
      ]
      ++ lib.optionals (cfg.client.links != [ ]) [
        "-links"
        (lib.concatStringsSep "," cfg.client.links)
      ]
      ++ lib.optionals (cfg.client.clientId != null) [
        "-client-id"
        cfg.client.clientId
      ]
      ++ lib.optionals (cfg.client.dnsMode != "auto") [
        "-dns-mode"
        cfg.client.dnsMode
      ]
      ++ lib.optionals (cfg.client.dnsServers != [ ]) [
        "-dns-servers"
        (lib.concatStringsSep "," cfg.client.dnsServers)
      ]
      ++ lib.optionals (cfg.client.subUrl != null) [
        "-sub"
        cfg.client.subUrl
      ]
      ++ commonFlags cfg.client;
      hardening = hardeningCommon;
      #? client caches VK creds next to the binary or in XDG_CONFIG_HOME
      environment.XDG_CONFIG_HOME = "/var/lib/free-turn-proxy-client";
    };

    networking.firewall.allowedUDPPorts = lib.mkIf (cfg.server.enable && cfg.server.openFirewall) [
      (lib.toInt (lib.last (lib.splitString ":" cfg.server.listen)))
    ];
  };
}
