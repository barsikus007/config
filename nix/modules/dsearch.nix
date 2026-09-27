{
  programs.dsearch = {
    enable = true;
    systemd.target = "graphical-session.target";
  };
}
