{ pkgs, ... }:
{
  home.packages = with pkgs; [ mcp-nixos ];

  programs.gemini-cli = {
    enable = true;
    # defaultModel = "gemini-3.1-pro-preview";
    settings = {
      #! https://github.com/nix-community/home-manager/pull/8707
      #? onboarding setted settings
      general.sessionRetention = {
        warningAcknowledged = true;
        enabled = true;
        maxAge = "120d";
      };
      security.auth.selectedType = "oauth-personal";
      ide.hasSeenNudge = true;

      general.enableNotifications = true;
      mcpServers = {
        nixos.command = "mcp-nixos";
      };
      modelConfigs = {
        customOverrides = [
          {
            match = {
              model = "gemini-3-flash-preview";
            };
            modelConfig = {
              generateContentConfig = {
                thinkingConfig = {
                  thinkingLevel = "HIGH";
                  includeThoughts = true;
                };
              };
            };
          }
        ];
      };
    };
    policies."allowed_run_shell_commands".rule =
      map
        (command: {
          toolName = "run_shell_command";
          commandPrefix = command;
          decision = "allow";
          priority = 100;
        })
        [
          "ls"
          "cat"
          "curl"
          "find"
          "grep"
          "head"
          "git status"
          "git log"
          # "notify-send"
        ];
    #? or settings.tools.allowed = [ "run_shell_command(ls)" ... ];
  };
}
