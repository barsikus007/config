{
  programs.codex.enable = true;
  programs.gemini-cli = {
    enable = true;
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
          "grep"
          "head"
          "git status"
          "git log"
        ];
  };
}
