{
  programs.gemini-cli = {
    enable = true;
    # defaultModel = "gemini-3.1-pro-preview";
    #! https://github.com/nix-community/home-manager/pull/8707
    # settings = {
    #   general = {
    #     enableNotifications = true; #? macos only wtf google
    #   };
    #   modelConfigs = {
    #     customOverrides = [
    #       {
    #         match = {
    #           model = "gemini-3-flash-preview";
    #         };
    #         modelConfig = {
    #           generateContentConfig = {
    #             thinkingConfig = {
    #               thinkingLevel = "HIGH";
    #               includeThoughts = true;
    #             };
    #           };
    #         };
    #       }
    #     ];
    #   };
    # };
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
        ];
  };
}
