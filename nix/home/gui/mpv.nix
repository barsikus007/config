{
  pkgs,
  config,
  flakePath,
  ...
}:
{
  programs.mpv = {
    enable = true;
    package =
      with pkgs;
      (mpv.override {
        scripts = with mpvScripts; [
          mpris
          uosc
          thumbfast
        ];
      });
  };
  xdg.configFile."mpv/".source = config.lib.file.mkOutOfStoreSymlink "${flakePath}/.config/mpv/";

  #! takes too long to open video, and works only with youtube...
  # home.packages = with pkgs; [ open-in-mpv ];
  # xdg.mimeApps.defaultApplications."x-scheme-handler/mpv" = "open-in-mpv.desktop";
}
