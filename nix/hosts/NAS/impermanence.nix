{ config, username, ... }:
{
  imports = [
    ../../modules/impermanence/on-zfs.nix
  ];

  environment.persistence.${config.custom.persist.dir} = {
    directories = [ ];
    users.${username} = {
      directories = [
        "Downloads"

        #? dev
        ".ssh"
        ".vscode-server"

        ".cache/.bun" # ? tools installed with bunx
        ".cache/tlrc"

        ".config/claude" # ? xdg-ninja
        ".config/litecli"

        ".local/share" # TODO: more

        ".local/state" # TODO: more
      ];
    };
  };
}
