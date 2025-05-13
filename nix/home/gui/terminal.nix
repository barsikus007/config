{ pkgs, ... }:
{
  programs.wezterm = {
    enable = true;
    package = pkgs.unstable.wezterm;
    extraConfig = builtins.readFile ../../.config/wezterm/wezterm.lua;
  };
  programs.neovide = {
    enable = true;
    settings = {
      grid = "120x30";
    };
  };
}
