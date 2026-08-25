{ pkgs, ... }:
{
  custom.persist.home.directories = [
    ".gemini"
    ".cache/cloud-code" # ? gemini auth
    ".config/opencode"
  ];

  home.packages = with pkgs; [ mcp-nixos ];

  programs.antigravity-cli.enable = true;
  programs.opencode.enable = true;
}
