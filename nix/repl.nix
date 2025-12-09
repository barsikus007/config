let
  flake = builtins.getFlake (toString ./.);
  nixos = flake.nixosConfigurations."ROG14";
in
nixos
// {
  inherit flake;
  home = builtins.head (builtins.attrValues nixos.config.home-manager.users);
  # home = flake.homeConfigurations."nixos".config;
}
