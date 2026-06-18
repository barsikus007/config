{
  lib,
  pkgs,
  config,
  ...
}:
#? for almost full-TUI yazi experience
#? https://github.com/sxyazi/yazi/blob/aa526434f00bb44e2e902d9a4ac5f810da1018b9/yazi-config/preset/yazi-default.toml
#? https://github.com/s0me1newithhand7s/reNixos/blob/2b1c380c75363a5d4e18a365fe675786428a0c58/hand7s/programs/yazi.nix
{
  home.packages = with pkgs; [
    viu
    tdf
    hexyl
    ouch
    epr
  ];
  programs.yazi.settings = {
    opener = {
      "play_mpv_tui" = [
        {
          run = "${lib.getExe config.programs.mpv.finalPackage} --vo=tct %s";
          block = true;
          for = "unix";
        }
      ];
      "play_mpv" = [
        {
          run = "${lib.getExe config.programs.mpv.finalPackage} %s";
          block = true;
          for = "unix";
        }
      ];
      "view_image_tui" = [
        {
          run = "${lib.getExe pkgs.viu} --transparent %s; read _";
          block = true;
          for = "unix";
        }
      ];
      "doc" = [
        {
          run = "${lib.getExe pkgs.tdf} %s";
          block = true;
          for = "unix";
        }
      ];
      "hex" = [
        {
          run = "${lib.getExe pkgs.hexyl} %s";
        }
      ];
      "exfil" = [
        {
          run = "${lib.getExe pkgs.ouch} d %s";
          block = true;
          for = "unix";
        }
      ];
      "book" = [
        {
          run = "${lib.getExe pkgs.epr} %s";
          block = true;
          for = "unix";
        }
      ];
    };

    open = {
      rules = [
        {
          mime = "text/*";
          use = [
            "edit"
            "hex"
            "open"
            "reveal"
          ];
        }
        {
          mime = "image/*";
          use = [
            "view_image_tui"
            "open"
            "reveal"
          ];
        }
        {
          mime = "{audio,video}/*";
          use = [
            "play_mpv_tui"
            "play_mpv"
            "open"
            "reveal"
          ];
        }
        {
          mime = "font/*";
          use = [
            "open"
            "edit"
            "reveal"
          ];
        }
        {
          mime = "application/epub+zip";
          use = [
            "book"
            "edit"
            "open"
            "reveal"
          ];
        }
        {
          mime = "application/pdf";
          use = [
            "doc"
            "open"
            "reveal"
          ];
        }
        {
          mime = "application/{octet-stream,x-executable,x-sharedlib,x-pie-executable}";
          use = [
            "hex"
            "edit"
            "open"
            "reveal"
          ];
        }
        {
          mime = "application/vnd.*";
          use = [
            "open"
            "edit"
            "reveal"
          ];
        }
        {
          mime = "application/{zip,rar,7z*,tar*,x-tar,x-bzip*,x-gzip,x-xz}";
          use = [
            "exfil"
            "open"
            "extract"
            "reveal"
          ];
        }
        {
          url = "*";
          use = [
            "open"
            "edit"
            "hex"
            "reveal"
          ];
        }
      ];
    };
  };
}
