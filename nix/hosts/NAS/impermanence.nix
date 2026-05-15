{ username, ... }:
let
  # TODO: config: persistentDir
  persistentDir = "/persistent";
in
{
  imports = [
    ../../modules/impermanence/on-zfs.nix
  ];

  environment.persistence."${persistentDir}" = {
    directories = [
      "/etc/ssh"
      "/var/db/sudo/lectured"
      "/var/log" # ? https://nixos.org/manual/nixos/unstable/#sec-var-journal
      "/var/lib/bluetooth"
    ];
    users.${username} = {
      directories = [
        "Downloads"

        "config"

        ".cache/tlrc"

        ".config/litecli"

        ".local/share" # TODO: more

        ".local/state" # TODO: more

        #? dev
        ".ssh"
        ".vscode-server"
      ];
    };
  };
}
