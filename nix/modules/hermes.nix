{
  lib,
  pkgs,
  config,
  inputs,
  username,
  ...
}:
{
  imports = [
    inputs.hermes-agent.nixosModules.default
  ];

  custom.persist.directories = [
    "/var/lib/hermes"
  ]
  ++ lib.optional (config.services.hermes-agent.container.backend == "podman") "/var/lib/containers";

  services.hermes-agent = {
    enable = true;
    package = inputs.hermes-agent.packages.${pkgs.stdenv.hostPlatform.system}.minimal.override {
      extraDependencyGroups = [
        "messaging"
        "edge-tts"
        "parallel-web"
        "voice"
        #! платно
        # "fal"
        # "exa"
        # "firecrawl"
        # "tts-premium"
        #! тоже платно или с условием
        # "anthropic"
        # "azure-identity"
        # "bedrock"
        # "daytona"
        # "dingtalk"
        # "feishu"
        # "modal"
        # "vercel"
      ];
    };
    addToSystemPackages = true;
    container = {
      #? pkexec docker exec -d hermes-agent /data/current-package/bin/hermes dashboard --port 9119 --host 127.0.0.1 --no-open
      #? http://localhost:9119
      #? pkexec docker exec hermes-agent /data/current-package/bin/hermes dashboard --stop
      enable = true;
      backend = if (config.virtualisation.docker.enable or false) then "docker" else "podman";
      hostUsers = [ ]; # fuck ~/.hermes placing
      extraOptions = [ "--env=HERMES_MANAGED=false" ];
    };
    settings = {
      auth.adopt_external_logins = false;
      updates.check = false;
      prompt_caching.cache_ttl = "auto"; # 1h for chatl 5m for agent
      telemetry.shared_metrics.enabled = false;
      terminal.timeout = 180;
    };
    mcpServers = lib.mapAttrs (_name: srv: {
      command = srv.command or null;
      args = srv.args or [ ];
      env = srv.env or { };
      url = srv.url or null;
      headers = srv.headers or { };
    }) (config.home-manager.users.${username}.programs.mcp.servers or { });

    extraPlugins = [
      (pkgs.fetchFromGitHub {
        owner = "roziscoding";
        repo = "hermes-telegram-guest-mode";
        rev = "ae227880697267f74ab5250eef33656a258b5ebc";
        hash = "sha256-cOfO/k1cL8yd5g1TFN3C9k+d+zi3+v5AGqzG73M71Ww=";
        name = "telegram-guest";
      })
    ];
  };
  #! to init before reboot
  #? export HERMES_HOME="/var/lib/hermes/.hermes"
  #? sg hermes -c "hermes gateway setup"
  #? sg hermes -c "hermes model"

  systemd.services.hermes-agent.preStart = lib.mkBefore ''
    systemd-tmpfiles --create --prefix=/var/lib/hermes
    chown -R ${config.services.hermes-agent.user}:${config.services.hermes-agent.group} /var/lib/hermes/home
    rm --force /var/lib/hermes/.hermes/.managed
  '';

  users.users.${username}.extraGroups = [ config.services.hermes-agent.group ];
}
