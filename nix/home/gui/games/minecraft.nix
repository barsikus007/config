{ pkgs, ... }:
{
  home.packages = with pkgs; [
    (prismlauncher.override {
      jdks = [
        jdk8
        # jdk11 #? could work with 1.12 - 1.16
        # jdk17 #? 1.17 - 1.18
        # jdk21 #? 1.19+
        jdk25
      ];
    })
  ];
}
