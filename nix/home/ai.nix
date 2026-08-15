{ pkgs, ... }:
{
  custom.persist.home.directories = [
    ".gemini"
    ".cache/cloud-code" # ? gemini auth
  ];

  home.packages = with pkgs; [ mcp-nixos ];

  programs.antigravity-cli.enable = true;
}
