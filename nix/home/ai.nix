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
    hooks = {
      "notify.sh" =
        let
          notify-send = lib.getExe' pkgs.libnotify "notify-send";
        in
        /* shell */ ''
          #!${lib.getExe pkgs.bash}

          # run detached in subshell so claude code never blocks
          (
            proj="$(basename "$PWD")"
            action=$(${notify-send} \
              --app-name='Claude Code' \
              --action=default=Focus \
              "Claude Code" \
              "$@")

            if [ -n "$action" ]; then
              wid=$(${lib.getExe pkgs.niri} msg --json windows | ${lib.getExe pkgs.jq} --raw-output --arg proj "$proj" '
                ([.[] | select(.app_id == "code" and (.title | test("(^| - )" + $proj + " - Visual Studio Code$")))] +
                 [.[] | select(.app_id == "code")] | .[0].id) // empty
              ')
              [ -n "$wid" ] && ${lib.getExe pkgs.niri} msg action focus-window --id "$wid"
            fi
          ) >/dev/null 2>&1 &
        '';
    };
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
      permissions.allow = [
        "WebFetch(domain:github.com)"
        "WebFetch(domain:github.io)"
        "WebFetch(domain:raw.githubusercontent.com)"
        "WebFetch(domain:readthedocs.io)"
        "WebFetch(domain:mozilla.org)"

        "WebSearch"

        "mcp__mcp-nixos"
        "Read(//nix/store/**)"
        "Bash(nix eval *)"
        "Bash(nix path-info *)"
        "Bash(nix search *)"
        "Bash(nixos-rebuild dry-build *)"

        "Read(//tmp/**)"
        "Edit(//tmp/**)"

        "Bash(curl:*)"
        "Bash(* --version)"
        "Bash(* --help *)"
        "Bash(fd *)"
        "Bash(rg *)"
        "Bash(gh search *)"
        "Bash(git status *)"

        "Bash(niri msg *)"

        "Bash(systemctl show *)"
        "Bash(systemctl status *)"
        "Bash(systemctl list-timers *)"
        "Bash(systemctl --user status *)"
        "Bash(systemctl --user show-environment)"
        "Bash(systemctl --user list-units *)"
        "Bash(systemctl --user list-timers *)"
        "Bash(journalctl *)"

        "Bash(dmesg *)"
        "Bash(lsmod)"
        "Bash(iw dev *)"
        "Bash(crontab -l)"
      ];
      hooks = {
        Stop = [
          {
            hooks = [
              {
                type = "command";
                command = "${config.xdg.configHome}/claude/hooks/notify.sh 'done'";
              }
            ];
          }
        ];
        PermissionRequest = [
          {
            hooks = [
              {
                type = "command";
                command = "${config.xdg.configHome}/claude/hooks/notify.sh --urgency=critical 'permission required'";
              }
            ];
          }
        ];
        PreToolUse = [
          {
            matcher = "AskUserQuestion";
            hooks = [
              {
                type = "command";
                command = "${config.xdg.configHome}/claude/hooks/notify.sh --urgency=critical 'waiting for input'";
              }
            ];
          }
        ];
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
