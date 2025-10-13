{
  programs.ssh.startAgent = true;

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
}
