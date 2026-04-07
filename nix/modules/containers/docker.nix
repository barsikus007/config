{
  username,
  rootless ? false,
  storageDriver ? null,
  ...
}:
{
  users.users.${username}.extraGroups = [ "docker" ];
  virtualisation.docker = {
    inherit storageDriver;
    enable = true;
    #? for better security and non-root bind mounts
    #! possibly will break smth
    daemon.settings.userns-remap = "default";
    rootless = {
      enable = rootless;
      setSocketVariable = true;
    };
  };
}
