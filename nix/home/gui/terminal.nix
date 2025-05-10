{ pkgs, ... }:
{
  programs.wezterm = {
    enable = true;
    package = pkgs.unstable.wezterm;
    extraConfig = builtins.readFile ../../.config/wezterm/wezterm.lua;
  };
}
