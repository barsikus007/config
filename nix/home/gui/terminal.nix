{
  xdg.mimeApps.associations.added."application/x-shellscript" = [ "org.wezfurlong.wezterm.desktop" ];
  xdg.terminal-exec.settings.default = "org.wezfurlong.wezterm.desktop";
  programs.zsh.shellAliases = {
    wt = "wezterm start --cwd ./";
  };
  programs.wezterm = {
    enable = true;
    extraConfig = builtins.readFile ../../.config/wezterm/wezterm.lua;
  };
  programs.neovide = {
    enable = true;
    settings = {
      grid = "120x30";
    };
  };
}
