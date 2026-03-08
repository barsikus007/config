{ inputs, ... }:
#! 111Mb
{
  imports = [ inputs.nix-index-database.homeModules.default ];
  programs.nix-index.enable = true;
  # programs.nix-index.enableBashIntegration = false;
  # programs.nix-index.enableZshIntegration = false;
  # programs.nix-index.enableFishIntegration = false;
}
