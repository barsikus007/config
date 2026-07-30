{
  lib,
  config,
  inputs,
  username,
  ...
}:
#? https://nix-community.github.io/preservation/impermanence-migration.html maybe
let
  cfg = config.custom.persist;
  hm = config.home-manager.users.${username}.custom.persist.home;
in
{
  imports = [
    inputs.impermanence.nixosModules.impermanence
  ];

  fileSystems.${cfg.dir}.neededForBoot = true;

  environment.persistence.${cfg.dir} = {
    hideMounts = true;

    directories = lib.unique (
      [
        # "/etc/ssh"
        # "/var/db" # ? ./sudo/lectured/$(id -u)

        "/var/lib/nixos" # ? https://nixos.org/manual/nixos/unstable/#sec-state-users
        "/var/lib/systemd" # ? https://nixos.org/manual/nixos/unstable/#sec-var-systemd

        # "/var/log" # ? https://nixos.org/manual/nixos/unstable/#sec-var-journal
      ]
      ++ cfg.directories
    );
    files = lib.unique (
      [
        # ! sadly, there is no way to pass secrets to initrd
        "/etc/machine-id" # ? https://nixos.org/manual/nixos/unstable/#sec-machine-id
      ]
      ++ cfg.files
    );
    users.${username} = {
      directories = lib.unique (
        [
          ".cache/nix" # ? URL -> store path / narHash mapping

          ".config/zsh"
        ]
        ++ cfg.home.directories
        ++ hm.directories
      );
      files = lib.unique (cfg.home.files ++ hm.files);
    };
  };
}
