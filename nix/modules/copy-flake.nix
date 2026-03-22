{ self, flakePath, ... }:
#? copy flake repo from store into expected location
{
  system.activationScripts.copyFlake = {
    text = ''
      if [ ! -d ${flakePath} ]; then
        mkdir --parents ${flakePath}
        cp --recursive ${self.outPath}/. ${flakePath}
        chown --recursive 1000:100 ${flakePath}
      fi
    '';
  };
}
