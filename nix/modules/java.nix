{ pkgs, ... }:
{
  programs.java = {
    enable = true;
    package = with pkgs; jdk25;
    binfmt = true;
  };
}
