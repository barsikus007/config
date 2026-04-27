{ inputs, username, ... }@args:
#? https://nix-community.github.io/preservation/impermanence-migration.html maybe
let
  persistentDir = if args ? persistentDir then args.persistentDir else "/persistent";
in
{
  imports = [
    inputs.impermanence.nixosModules.impermanence
  ];

  environment.persistence."${persistentDir}" = {
    hideMounts = true;

    directories = [
      # "/etc/ssh"
      # "/var/db" # ? ./sudo/lectured/$(id -u)

      "/var/lib/nixos" # ? https://nixos.org/manual/nixos/unstable/#sec-state-users
      "/var/lib/systemd" # ? https://nixos.org/manual/nixos/unstable/#sec-var-systemd

      # "/var/log" # ? https://nixos.org/manual/nixos/unstable/#sec-var-journal
    ];
    files = [
      # ! sadly, there is no way to pass secrets to initrd
      "/etc/machine-id" # ? https://nixos.org/manual/nixos/unstable/#sec-machine-id
    ];
    users.${username} = {
      directories = [
        ".cache/nix" # ? URL -> store path / narHash mapping

        ".config/zsh"
      ];
    };
  };
}
