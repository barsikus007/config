{ pkgs, ... }:
{
  home.packages = with pkgs; [
    (prismlauncher.override {
      jdks = [
        # jdk8
        graalvmPackages.graalvm-oracle_17
        # jdk21
        graalvmPackages.graalvm-oracle
      ];
    })
  ];
}
