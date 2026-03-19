{ pkgs, config, ... }:
#! https://github.com/svenstaro/rofi-calc/issues/33
{
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
}
