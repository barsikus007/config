{
  pkgs,
  config,
  username,
  ...
}:
{
  sops.secrets."hosts/${config.system.name}/smb/passwd" = { };

  system.activationScripts.samba-passwd = {
    deps = [ "setupSecrets" ];
    text = ''
      password=$(cat ${config.sops.secrets."hosts/${config.system.name}/smb/passwd".path})
      printf "$password\n$password\n" \
        | ${config.services.samba.package}/bin/smbpasswd -sa ${username}
    '';
  };

  services.samba = {
    enable = true;
    package = with pkgs; samba4Full;
    openFirewall = true;
    settings = {
      global = {
        #? acl_xattr: store Windows ACLs as xattr
        #? fruit+streams_xattr: macOS SMB quirks and resource fork support
        #? io_uring: async I/O for better throughput (must be last parameter)
        "vfs objects" = "acl_xattr fruit streams_xattr io_uring";
      };

      "storage" = {
        "path" = "/tank/storage";
        "read only" = "no";
        "valid users" = username; # ? all users are valid by default
        "hide files" = "/_*/";
      };
    };
  };

  services.samba-wsdd = {
    enable = true;
    openFirewall = true;
  };

  services.avahi = {
    enable = true;
    openFirewall = true;
    nssmdns4 = true; # ? resolve .local hostnames (e.g. nas.local)
    publish = {
      enable = true;
      userServices = true; # ? let samba auto-register SMB service in mDNS
    };
  };
}
