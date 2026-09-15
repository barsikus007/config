{
  custom.persist.home.directories = ".cache/danksearch";

  programs.dsearch = {
    enable = true;
    systemd.target = "graphical-session.target";
  };
}
