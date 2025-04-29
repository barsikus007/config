{ config, pkgs, ... }:

{
  programs.mpv = {
    enable = true;
    package = (
      pkgs.mpv-unwrapped.wrapper {
        scripts = with pkgs.mpvScripts; [
          uosc
          thumbfast
        ];

        mpv = pkgs.mpv-unwrapped.override {
          waylandSupport = true;
        };
      }
    );
  };
  xdg.configFile."mpv" = {
    source = ../../.config/mpv;
  };
}
