{
  username,
  rootless ? false,
  ...
}:
{
  users.users.${username}.extraGroups = [ "docker" ];
  virtualisation.docker = {
    enable = true;
    storageDriver = "btrfs";
    rootless = {
      enable = rootless;
      setSocketVariable = true;
    };
  };
}
