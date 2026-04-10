{
  lib,
  self,
  pkgs,
  flakePath,
  ...
}:
#? copy flake repo from store into expected location
{
  system.activationScripts.copyFlake = {
    text = ''
      if [ ! -d ${flakePath} ]; then
        install --directory --owner=1000 --group=100 $(dirname ${flakePath}) ${flakePath}
        ${lib.getExe pkgs.rsync} --archive --chown=1000:100 ${self.outPath}/. ${flakePath}
      fi
    '';
  };
}
