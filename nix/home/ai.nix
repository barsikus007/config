{
  lib,
  pkgs,
  config,
  ...
}:
{
  custom.persist.home.directories = [
    ".gemini"
    ".cache/cloud-code" # ? gemini auth
    ".config/codex"
    ".config/opencode"
  ];

  home.packages = with pkgs; [
    mcp-nixos
    paseo
    paseo-desktop
  ];
  programs.mcp = {
    enable = true;
    servers = {
      mcp-nixos.command = lib.getExe pkgs.mcp-nixos;
    };
  };

  programs.antigravity-cli.enable = true;
  programs.claude-code = {
    enable = true;
    package =
      (pkgs.writeShellScriptBin "claude" ''
        exec ${lib.getExe pkgs.bun} x @anthropic-ai/claude-code@next "$@"
      '')
      // {
        #? disable eval warn
        version = "2.1.157";
      };
    mutableSettings = true;
    enableMcpIntegration = true;
    configDir = "${config.xdg.configHome}/claude";
    settings = {
      cleanupPeriodDays = 365;
      attribution = {
        commit = "";
        pr = "";
      };
      timeFormat = "24-hour";
      tui = "fullscreen";
      env = {
        CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC = "1";
        DISABLE_TELEMETRY = "1";
      };
    };
  };
  programs.codex.enable = true;
  programs.opencode = {
    enable = true;
    package = pkgs.writeShellScriptBin "opencode" ''
      exec ${lib.getExe pkgs.bun} x opencode-ai@latest "$@"
    '';
  };
  systemd.user.services.paseo = {
    Unit = {
      Description = "Paseo remote agent sessions";
      After = [ "network-online.target" ];
      Wants = [ "network-online.target" ];
    };
    Install = {
      WantedBy = [ "default.target" ];
    };
    Service = {
      Environment = [
        "PASEO_HOME=${config.xdg.dataHome}/paseo"
        "PASEO_LISTEN=0.0.0.0:6767"
        "PASEO_RELAY_ENABLED=false"
        "PASEO_WEB_UI_ENABLED=true"
      ];
      ExecStart = "${lib.getExe pkgs.zsh} -lc 'exec ${lib.getExe' pkgs.paseo "paseo-server"}'";
      Restart = "on-failure";
      RestartSec = 5;

      KillSignal = "SIGTERM";
      TimeoutStopSec = 15;
    };
  };
}
