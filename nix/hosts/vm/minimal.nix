{ config, username, ... }:
{
  imports = [
    ../minimal.nix
    ../../modules/copy-flake.nix
    #? to compile completions at NixOS buildtime
    ../../shared/zsh-compinit.nix
  ];
  virtualisation.vmVariant.virtualisation.forwardPorts = [
    #? ssh localhost -p 22222 -o StrictHostKeychecking=no -o ConnectionAttempts=60
    {
      from = "host";
      host.port = 22222;
      guest.port = builtins.elemAt config.services.openssh.ports 0;
    }
  ];

  #? autologin
  security.sudo.wheelNeedsPassword = false;
  services.getty.autologinUser = username;
  services.displayManager.autoLogin.enable = true;
  services.displayManager.autoLogin.user = username;

  #? guest tools
  #! 250Kb
  services.qemuGuest.enable = true;
  services.spice-vdagentd.enable = true;
  services.spice-autorandr.enable = true;
}
