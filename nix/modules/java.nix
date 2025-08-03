{ pkgs, ... }:
{
  programs.java = {
    enable = true;
    package = pkgs.graalvmPackages.graalvm-oracle;
    binfmt = true;
  };
}
