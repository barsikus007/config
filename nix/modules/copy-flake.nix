{
  lib,
  pkgs,
  self,
  config,
  username,
  flakePath,
  ...
}:
#? copy flake repo from store into expected location
let
  user = config.users.users.${username};
  uid = toString user.uid;
  gid = toString config.users.groups.${user.group}.gid;
in
{
  system.activationScripts.copyFlake = {
    deps = [ "users" ];
    text = ''
      if [ ! -d ${flakePath} ]; then
        install --directory --owner=${uid} --group=${gid} --mode=0755 $(dirname ${flakePath}) ${flakePath}
        ${lib.getExe pkgs.rsync} --archive --chmod=u+w --chown=${uid}:${gid} ${self.outPath}/. ${flakePath}
      fi
    '';
  };
}
