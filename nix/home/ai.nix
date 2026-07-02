{ pkgs, ... }:
{
  home.packages = with pkgs; [ mcp-nixos ];

  programs.antigravity-cli = {
    enable = true;
    # defaultModel = "gemini-3.1-pro-preview";
    settings.enableTelemetry = false;
    mcpServers = {
      nixos.command = "mcp-nixos";
    };
    permissions.allow = [
      #? WebFetch(domain -> read_url
      #? Bash -> command
      #? Read -> read_file
      "read_url(github.com)"
      "read_url(raw.githubusercontent.com)"
      "read_url(readthedocs.io)"
      # "WebSearch"
      # "mcp__voicemode__converse"
      # "mcp__voicemode__service"
      "mcp(mcp-nixos/*)"
      # "mcp__mcp-nixos__nix_versions"
      "read_file(//nix/store/**)"
      "command(nixd --version)"
      "command(nix --version)"
      "command(nix search *)"
      "command(nixos-rebuild dry-build *)"
      "read_file(//tmp/**)"
      "command(curl:*)"
      "command(* --version)"
      "command(* --help *)"
      "command(fd *)"
      "command(rg *)"
      "command(gh search *)"
      "command(git status *)"
      "command(systemctl show *)"
      "command(systemctl status *)"
      "command(journalctl *)"
    ];
  };
}
