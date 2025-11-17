{
  programs.throne = {
    #? https://github.com/throneproj/Throne/issues/720#issuecomment-3223685757
    #! Settings -> Basic settings -> Core -> Core Options -> Underlying DNS: `tcp://1.0.0.1`
    enable = true;
    tunMode = {
      enable = true;
      # TODO is this needed? reboot autostart related?
      # setuid = true;
    };
  };
}
