{
  lib,
  config,
  username,
  ...
}:
{
  imports = [
    ./local.nix

    ../../../sops.nix
  ];
  sops.secrets."hosts/${config.system.name}/smb/passwd" = { };

  systemd.services.samba-passwd = {
    description = "provision samba password for ${username} from sops secret";
    wantedBy = [ "multi-user.target" ];
    before = [ "samba-smbd.service" ];
    unitConfig.ConditionPathExists = config.sops.secrets."hosts/${config.system.name}/smb/passwd".path;
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
    script =
      let
        smbpasswd = lib.getExe' config.services.samba.package "smbpasswd";
      in
      /* shell */ ''
        password=$(cat ${config.sops.secrets."hosts/${config.system.name}/smb/passwd".path})
        printf "$password\n$password\n" | ${smbpasswd} -sa ${username}
      '';
  };

  services.samba = {
    enable = true;
    openFirewall = true;
    settings = {
      #! https://www.samba.org/samba/docs/current/man-html/smb.conf.5.html
      "storage" = {
        "path" = "/tank/storage";
        "read only" = "no";
        "valid users" = username; # ? all users are valid by default
        "hide files" = "/_*/";
      };
    };
  };
}
