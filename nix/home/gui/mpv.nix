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
  xdg.configFile."mpv".source = config.lib.file.mkOutOfStoreSymlink "${flakePath}/.config/mpv";
}
