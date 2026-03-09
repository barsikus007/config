{
  self,
  username,
  flakePath,
  ...
}:
{
  imports = [
    ../../hosts/minimal.nix
    #? to compile completions at NixOS buildtime
    ../../shared/zsh-compinit.nix
  ];
  virtualisation.vmVariant.virtualisation.forwardPorts = [
    #? ssh localhost -p 22222 -o StrictHostKeychecking=no -o ConnectionAttempts=60
    {
      from = "host";
      host.port = 22222;
      guest.port = 2222;
    }
  ];

  #? autologin
  security.sudo.wheelNeedsPassword = false;
  services.getty.autologinUser = username;
  services.displayManager.autoLogin.enable = true;
  services.displayManager.autoLogin.user = username;

  # TODO: same for iso
  system.activationScripts.copyFlake = {
    text = ''
      if [ ! -d ${flakePath} ]; then
        mkdir --parents ${flakePath}
        cp --recursive ${self.outPath}/. ${flakePath}
        chown --recursive 1000:100 ${flakePath}
      fi
    '';
  };

  #? guest tools
  #! 250Kb
  services.qemuGuest.enable = true;
  services.spice-vdagentd.enable = true;
  services.spice-autorandr.enable = true;
}
