{
  pkgs,
  config,
  flakePath,
  ...
}:
{
  imports = [
    # inputs.niri.homeModules.niri
    # inputs.niri.homeModules.stylix

    ./quickshell/noctalia.nix
  ];
  home.packages = with pkgs; [
    grim
    slurp
    playerctl
    brightnessctl
  ];

  #! https://github.com/sodiboo/niri-flake/issues/1393
  # programs.niri = {
  #   enable = false;
  #   package = with pkgs; niri;
  #   settings = {
  #   };
  # };

  services.polkit-gnome.enable = true; # polkit
  #? /wiki

  xdg.configFile."niri/config.kdl".source =
    config.lib.file.mkOutOfStoreSymlink "${flakePath}/.config/niri/config.kdl";
}
