{ pkgs, ... }:
{
  services.cliphist = {
    enable = true;
    #! https://github.com/YaLTeR/wl-clipboard-rs/issues/5
    #! https://github.com/bugaevc/wl-clipboard/issues/268
    # clipboardPackage =
    #   with pkgs;
    #   wl-clipboard.overrideAttrs {
    #     version = "2.2.1-git";

    #     src = fetchFromGitHub {
    #       owner = "bugaevc";
    #       repo = "wl-clipboard";
    #       rev = "e8082035dafe0241739d7f7d16f7ecfd2ce06172";
    #       hash = "sha256-sR/P+urw3LwAxwjckJP3tFeUfg5Axni+Z+F3mcEqznw=";
    #     };
    #   };
  };
  home.file.".face.icon".source = builtins.fetchurl {
    url = "https://github.com/barsikus007.png";
    sha256 = "sha256-ifkRxN8PTXOp7zkM8NcEWptT7scvMVkGZlcUs6B+0Dk=";
  };
}
