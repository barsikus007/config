{
  lib,
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
    "/var/lib/containers"
  ];

  services.hermes-agent = {
    enable = true;
    addToSystemPackages = true;
    container = {
      enable = true;
      backend = "podman";
      hostUsers = [ ]; # fuck ~/.hermes placing
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
  };
  #! to init before reboot
  #? export HERMES_HOME="/var/lib/hermes/.hermes"
  #? sg hermes -c "hermes gateway setup"
  #? sg hermes -c "hermes model"

  systemd.services.hermes-agent.preStart = lib.mkBefore ''
    systemd-tmpfiles --create --prefix=/var/lib/hermes
  '';

  users.users.${username}.extraGroups = [ config.services.hermes-agent.group ];
}
