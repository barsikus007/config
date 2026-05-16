{
  lib,
  config,
  username,
  ...
}:
let
  fromNAS =
    names:
    lib.genAttrs names (_: {
      sopsFile = ../../secrets/hosts/NAS.yaml;
    });
in
{
  imports = [ ../../modules/sops.nix ];

  sops.defaultSopsFile = ../../secrets/secrets.yaml;
  sops.age.keyFile = "/persistent/home/${username}/.config/sops/age/keys.txt";

  sops.secrets = lib.attrsets.mergeAttrsList [
    { "tokens/github_nix" = { }; }
    (fromNAS [
      "hosts/NAS/smb/user"
      "hosts/NAS/smb/passwd"
      "hosts/NAS/router/ssid"
    ])
  ];

  nix.extraOptions = "!include ${config.sops.secrets."tokens/github_nix".path}";
  sops.templates."smb-credentials" = {
    content = ''
      username=${config.sops.placeholder."hosts/NAS/smb/user"}
      password=${config.sops.placeholder."hosts/NAS/smb/passwd"}
    '';
  };
}
