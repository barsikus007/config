{ lib, pkgs, ... }:
{
  custom.persist.home.directories = [
    ".gemini"
    ".cache/cloud-code" # ? gemini auth
    ".config/codex"
    ".config/opencode"
  ];

  home.packages = with pkgs; [ mcp-nixos ];
  programs.mcp = {
    enable = true;
    servers = {
      mcp-nixos.command = lib.getExe pkgs.mcp-nixos;
    };
  };

  programs.antigravity-cli.enable = true;
  programs.codex.enable = true;
  programs.opencode = {
    enable = true;
    package = pkgs.writeShellScriptBin "opencode" ''
      exec ${lib.getExe pkgs.bun} x opencode-ai@latest "$@"
    '';
  };
}
