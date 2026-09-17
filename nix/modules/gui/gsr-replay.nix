{
  lib,
  config,
  username,
  ...
}:
let
  systemctl = lib.getExe' config.systemd.package "systemctl";
  userctl = "${systemctl} --no-block --machine=${username}@ --user";
in
{
  custom.persist.home.directories = [ ".config/gpu-screen-recorder" ];

  home-manager.users.${username}.imports = [ ../../home/desktop/gsr-replay.nix ];

  #? overlay and replay live in every profile except power-saver
  #? (power-profile-select maps battery to power-saver)
  #? fails silently when the user is not logged in; the login path is ExecCondition in the unit
  custom.powerProfiles.actions.gsr-ui = {
    performance = "${userctl} start gsr-ui.service";
    balanced = "${userctl} start gsr-ui.service";
    powerSaver = "${userctl} stop gsr-ui.service";
  };

  services.udev.extraRules = ''
    ACTION=="change", SUBSYSTEM=="drm", ENV{HOTPLUG}=="1", RUN+="${userctl} start gsr-ui-monitor-hotplug.service"
  '';
}
