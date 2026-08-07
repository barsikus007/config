{ pkgs, ... }:
{
  programs.java = {
    enable = true;
    package = pkgs.jdk25;
    binfmt = true;
  };
}
