{
  # users.defaultUserShell = pkgs.fish;

  # programs.bash = {
  #   interactiveShellInit = ''
  #     if [[ $(${lib.getExe pkgs.procps} --no-header --pid=$PPID --format=comm) != "fish" && -z ''${BASH_EXECUTION_STRING} ]]
  #     then
  #       shopt -q login_shell && LOGIN_OPTION='--login' || LOGIN_OPTION=""
  #       exec ${lib.getExe pkgs.fish} $LOGIN_OPTION
  #     fi
  #   '';
  # };
  programs.fish = {
    enable = true;
    useBabelfish = true;
  };
}
