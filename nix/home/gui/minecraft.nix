{ pkgs, ... }:
{
  programs.java = {
    enable = true;
    package = pkgs.graalvmPackages.graalvm-oracle;
  };
  home.packages = with pkgs; [ prismlauncher ];
}
