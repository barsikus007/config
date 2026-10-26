{
  programs.dux-search = {
    enable = true;
    systemd.target = "graphical-session.target";
  };
}
