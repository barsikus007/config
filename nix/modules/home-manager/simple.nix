{ username, ... }: {
  home-manager.users.${username} = {
    imports = [
      ../../home
      ../../home/shell/minimal.nix
    ];
  };
}
