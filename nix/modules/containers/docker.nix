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
    rootless = {
      enable = rootless;
      setSocketVariable = true;
    };
  };
}
