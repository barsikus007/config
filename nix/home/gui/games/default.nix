{
  custom.persist.home.directories = [ ".config/ludusavi" ];

  services.ludusavi.enable = true;
  xdg.configFile."ludusavi/config.yaml".enable = false;
}
