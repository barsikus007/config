{ pkgs, ... }:
{
  programs.java = {
    enable = true;
    package = pkgs.unstable.graalvmPackages.graalvm-oracle;
  };
  home.packages = with pkgs; [ prismlauncher ];
}
