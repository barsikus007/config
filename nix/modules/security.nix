{ self, pkgs, ... }:
{
  #? https://wiki.nixos.org/wiki/SSH_public_key_authentication#KDE
  programs.ssh = {
    startAgent = true;
    enableAskPassword = true;
  };
  environment.variables = {
    SSH_ASKPASS_REQUIRE = "prefer";
  };

  security.polkit.debug = true;
  security.polkit.extraConfig = ''
    /* Allow members of the wheel group to execute the defined actions
     * without password authentication, similar to "sudo NOPASSWD:"
     */
    polkit.addRule(function(action, subject) {
        if ((
            action.id == "org.freedesktop.udisks2.filesystem-mount-system" ||
            action.id == "org.freedesktop.udisks2.encrypted-unlock-system"
        ) && subject.isInGroup("wheel"))
        {
            return polkit.Result.YES;
        }
    });
  '';

  environment.systemPackages = [
    self.packages.${pkgs.stdenv.hostPlatform.system}.gui.keepassxc
  ];
}
