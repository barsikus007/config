{ username, ... }@args:
let
  rootless = args.rootless or false;
  #? for better security and non-root bind mounts
  #! breaks at least nextcloud-aio and grafana
  usernsRemap = args.usernsRemap or false;
in
{
  users.users.${username}.extraGroups = [ "docker" ];
  virtualisation.oci-containers.backend = "docker";
  virtualisation.docker = {
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
