{
  lib,
  config,
  inputs,
  username,
  ...
}:
let
  cfg = config.custom.persist;
  hm = config.home-manager.users.${username}.custom.persist.home;
in
{
  imports = [
    inputs.impermanence.nixosModules.impermanence
  ];
  #? state of services whose `enable` may come from a foreign module (plasma6, nixos-hardware),
  #? so key on the option itself instead of on whoever turned it on
  custom.persist = {
    directories =
      lib.optional config.services.power-profiles-daemon.enable "/var/lib/power-profiles-daemon" # ? selected power-profile
      ++ lib.optional config.services.upower.enable "/var/lib/upower"; # ? history of power usage
    home.directories = lib.optional config.programs.dsearch.enable ".cache/danksearch"; # ? index
  };

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
