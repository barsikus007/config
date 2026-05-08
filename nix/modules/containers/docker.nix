{ username, ... }@args:
let
  rootless = if args ? rootless then args.rootless else false;
  storageDriver = if args ? storageDriver then args.storageDriver else null;
  #? for better security and non-root bind mounts
  #! breaks at least nextcloud-aio and grafana
  usernsRemap = if args ? usernsRemap then args.usernsRemap else false;
in
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
// (
  if usernsRemap then
    {
      virtualisation.docker.daemon.settings.userns-remap = "default";
      users.users.dockremap = {
        isSystemUser = true;
        group = "dockremap";
        subUidRanges = [
          {
            startUid = 100000;
            count = 65536;
          }
        ];
        subGidRanges = [
          {
            startGid = 100000;
            count = 65536;
          }
        ];
      };
      users.groups.dockremap = { };
    }
  else
    { }
)
