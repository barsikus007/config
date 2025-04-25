{ pkgs, unstable, ... }:
{
  programs.java = {
    enable = true;
    package = unstable.graalvmPackages.graalvm-oracle;
  };
  home.packages = with pkgs; [ prismlauncher ];
}
