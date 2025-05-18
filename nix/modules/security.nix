{ username, ... }:
{
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
    /* nekoray tun mode fixes */
    polkit.addRule(function(action, subject) {
        if (
            action.id == "org.freedesktop.policykit.exec" && (
                action.lookup("command_line") == "/home/${username}/.nix-profile/bin/bash /home/${username}/.config/nekoray/config/vpn-run-root.sh" ||
                action.lookup("command_line").startsWith("/run/current-system/sw/bin/pkill -2 -P")
        ) && subject.isInGroup("wheel"))
        {
            // return polkit.Result.YES;
            return polkit.Result.AUTH_ADMIN_KEEP;
        }
    });
  '';
}
