{ username, ... }:
#? windows-like folder sharing
#! windows now works differently
#? reg add HKLM\SYSTEM\CurrentControlSet\Services\LanmanWorkstation\Parameters /v AllowInsecureGuestAuth /t REG_DWORD /d 1 /f ; net stop workstation ; net start workstation
{
  imports = [ ./local.nix ];

  services.samba = {
    enable = true;
    openFirewall = true;
    settings = {
      #! https://www.samba.org/samba/docs/current/man-html/smb.conf.5.html
      global = {
        #? global-only: unknown users become guest (only for shares with "guest ok")
        #? keep default guest account (nobody); writes are handled by the share's "force user"
        "map to guest" = "Bad User";

        #? answer name queries, but stay out of the browser election NAS already wins
        "local master" = "no";
        "os level" = "0";
      };

      "Share" = {
        "path" = "/home/${username}/Share";
        "read only" = "no";
        "guest ok" = "yes";
        "force user" = username;
      };
    };
  };
}
