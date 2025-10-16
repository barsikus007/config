{
  xdg.mimeApps.defaultApplications = {
    "application/x-shellscript" = [ "WezTerm.desktop" ];
  };
  programs.zsh.shellAliases = {
    wt = "wezterm";
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
