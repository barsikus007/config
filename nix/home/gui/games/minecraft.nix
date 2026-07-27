{ pkgs, ... }:
{
  home.packages = with pkgs; [
    (prismlauncher.override {
      jdks = [
        jdk8
        # jdk17 # ? 1.17 - 1.20.4
        jdk21 # ? 1.20.5
        jdk25 # ? GTNH
      ];
    })
  ];
}
