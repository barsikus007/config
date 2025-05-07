{ pkgs, ... }:
{
  programs.wezterm = {
    enable = true;
    # TODO: unstable 25.05
    package = pkgs.unstable.wezterm;
    extraConfig = builtins.readFile ../../.config/wezterm/wezterm.lua;
  };
}
