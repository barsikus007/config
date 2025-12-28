let
  flake = builtins.getFlake (toString ./.);
  nixos = flake.nixosConfigurations."ROG14";
  inherit (nixos) config options;
in
nixos
// {
  inherit flake;
  home = builtins.head (builtins.attrValues config.home-manager.users) // {
    options = options.home-manager.users.type.getSubOptions [ ];
  };
  # home = flake.homeConfigurations."nixos".config;
}
