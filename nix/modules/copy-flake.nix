{
  lib,
  self,
  pkgs,
  config,
  username,
  flakePath,
  ...
}:
#? copy flake repo from store into expected location
let
  uid = toString config.users.users.${username}.uid;
in
{
  system.activationScripts.copyFlake = {
    text = ''
      if [ ! -d ${flakePath} ]; then
        install --directory --owner=${uid} --group=100 $(dirname ${flakePath}) ${flakePath}
        ${lib.getExe pkgs.rsync} --archive --chown=${uid}:100 ${self.outPath}/. ${flakePath}
      fi
    '';
  };
}
