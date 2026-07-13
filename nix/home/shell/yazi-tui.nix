{
  lib,
  pkgs,
  config,
  ...
}:
#? for almost full-TUI yazi experience
#? https://github.com/sxyazi/yazi/blob/aa526434f00bb44e2e902d9a4ac5f810da1018b9/yazi-config/preset/yazi-default.toml
#? https://github.com/s0me1newithhand7s/reNixos/blob/2b1c380c75363a5d4e18a365fe675786428a0c58/hand7s/programs/yazi.nix
let
  mpvEnabled = config.programs.mpv.enable;
  default = [
    "reveal"
    "nix_copy_edit"
  ];
  defaultText = [
    "edit"
    "hex"
    "open"
  ]
  ++ default;
in
{
  home.packages = with pkgs; [
    viu
    tdf
    hexyl
    ouch
    epr
  ];
  programs.yazi.settings = {
    opener =
      lib.optionalAttrs mpvEnabled {
        "play_mpv" = [
          {
            run = "${lib.getExe config.programs.mpv.finalPackage} --vo=tct %s";
            desc = "Play video TUI";
            block = true;
            for = "unix";
          }
          {
            run = "${lib.getExe config.programs.mpv.finalPackage} %s";
            desc = "Play video";
            block = true;
            for = "unix";
          }
        ];
      }
      // {
        "view_image_tui" = [
          {
            run = "${lib.getExe pkgs.viu} --transparent %s; read _";
            desc = "View image TUI";
            block = true;
            for = "unix";
          }
        ];
        "open" = [
          {
            run = "code --reuse-window %s";
            desc = "Open in VSCode";
            orphan = true;
          }
          {
            run = "xdg-open %s1";
            desc = "Open";
            for = "linux";
          }
          {
            run = "open %s";
            desc = "Open";
            for = "macos";
          }
          {
            run = "termux-open %s1";
            desc = "Open";
            for = "android";
          }
        ];
        "doc" = [
          {
            run = "${lib.getExe pkgs.tdf} %s";
            desc = "View PDF";
            block = true;
            for = "unix";
          }
        ];
        "hex" = [
          {
            run = "${lib.getExe pkgs.hexyl} %s | bat --style=plain; read _";
            desc = "View HEX";
            block = true;
            for = "unix";
          }
        ];
        "exfil" = [
          {
            run = "${lib.getExe pkgs.ouch} decompress %s";
            desc = "Extract here";
            block = true;
            for = "unix";
          }
        ];
        "book" = [
          {
            run = "${lib.getExe pkgs.epr} %s";
            desc = "View EPUB";
            block = true;
            for = "unix";
          }
        ];
        "nix_copy_edit" = [
          {
            run = "zsh -c 'nix_copy_edit %s'";
            desc = "Nix copy and edit";
            block = true;
            for = "unix";
          }
        ];
      };

    open = {
      rules = [
        {
          mime = "text/*";
          use = defaultText;
        }
        {
          mime = "image/*";
          use = [
            "view_image_tui"
            "open"
          ]
          ++ default;
        }
        {
          mime = "audio/*";
          use =
            lib.optionals mpvEnabled [
              "play_mpv_tui"
              "play_mpv"
            ]
            ++ [
              "open"
            ]
            ++ default;
        }
        {
          mime = "video/*";
          use =
            lib.optionals mpvEnabled [
              "play_mpv"
              "play_mpv_tui"
            ]
            ++ [
              "open"
            ]
            ++ default;
        }
        {
          mime = "font/*";
          use = [
            "open"
            "edit"
          ]
          ++ default;
        }
        {
          mime = "application/{json,ndjson,javascript,wine-extension-ini}";
          use = defaultText;
        }
        {
          mime = "application/epub+zip";
          use = [
            "book"
            "edit"
            "open"
          ]
          ++ default;
        }
        {
          mime = "application/pdf";
          use = [
            "doc"
            "open"
          ]
          ++ default;
        }
        {
          mime = "application/{octet-stream,x-executable,x-sharedlib,x-pie-executable}";
          use = [
            "hex"
            "edit"
            "open"
          ]
          ++ default;
        }
        {
          mime = "application/vnd.*";
          use = [
            "open"
            "edit"
          ]
          ++ default;
        }
        {
          mime = "application/{zip,rar,7z*,tar*,x-tar,x-bzip*,x-gzip,x-xz}";
          use = [
            "exfil"
            "open"
            "extract"
          ]
          ++ default;
        }
        {
          mime = "inode/empty";
          use = defaultText;
        }
        {
          mime = "vfs/{absent,stale}";
          use = "download";
        }
        {
          url = "*";
          use = [
            "open"
            "edit"
            "hex"
          ]
          ++ default;
        }
      ];
    };
  };
}
