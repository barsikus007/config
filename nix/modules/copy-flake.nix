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
    text = ''
      if [ ! -d ${flakePath} ]; then
        install --directory --owner=${uid} --group=${gid} $(dirname ${flakePath}) ${flakePath}
        ${lib.getExe pkgs.rsync} --archive --chown=${uid}:${gid} ${self.outPath}/. ${flakePath}
      fi
    '';
  };
}
