{
  lib,
  pkgs,
  config,
  ...
}:
#! https://github.com/svenstaro/rofi-calc/issues/33
{
  services.cliphist = {
    enable = true;
    #! https://github.com/bugaevc/wl-clipboard/issues/268
    #! https://github.com/YaLTeR/wl-clipboard-rs/issues/5
    clipboardPackage =
      with pkgs;
      wl-clipboard.overrideAttrs {
        version = "2.2.1-git";

        src = fetchFromGitHub {
          owner = "bugaevc";
          repo = "wl-clipboard";
          rev = "e8082035dafe0241739d7f7d16f7ecfd2ce06172";
          hash = "sha256-sR/P+urw3LwAxwjckJP3tFeUfg5Axni+Z+F3mcEqznw=";
        };
      };
  };
  programs.rofi = {
    enable = true;
    plugins = with pkgs; [
      rofi-calc
      rofi-file-browser
      rofi-emoji
    ];
    # pass
    theme =
      let
        # Use `mkLiteral` for string-like values that should show without
        # quotes, e.g.:
        # {
        #   foo = "abc"; => foo: "abc";
        #   bar = mkLiteral "abc"; => bar: abc;
        # };
        inherit (config.lib.formats.rasi) mkLiteral;
      in
      {
        "*" = {
          foreground-color = mkLiteral "rgba ( 250, 251, 252, 100 % )";
          width = 512;
        };
        "window" = {
          border = 8;
        };
        "#inputbar" = {
          children = map mkLiteral [
            "prompt"
            "entry"
          ];
        };

        "#textbox-prompt-colon" = {
          expand = false;
          str = ":";
          margin = mkLiteral "0px 0.3em 0em 0em";
          text-color = mkLiteral "@foreground-color";
        };
      };
  };
  programs.plasma = lib.mkIf config.programs.plasma.enable {
    hotkeys.commands."rofi" = {
      name = "chuvak eto rofis";
      key = "Ctrl+Alt+Space";
      # TODO https://github.com/svenstaro/rofi-calc/issues/33
      command = "rofi -show combi -show-icons";
    };
    #! no other way vi klipper https://bugs.kde.org/show_bug.cgi?id=427214
    # TODO disable klipper
    # TODO pins https://github.com/sentriz/cliphist/issues/23
    # TODO css big images
    # TODO css split text
    # TODO cancel on esc
    # TODO appear under cursor or better - above focus
    hotkeys.commands."rofi-cb" = {
      name = "chuvak eto rofis-cb";
      key = "Ctrl+Meta+V";
      #? https://github.com/sentriz/cliphist/issues/111
      command = "zsh -c \"rofi -modi clipboard:cliphist-rofi-img -show clipboard -show-icons && ${pkgs.ydotool} key 29:1 47:1 47:0 29:0\"";
    };
  };
}
