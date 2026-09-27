#? Да.
{
  imports = [
    ./discord.nix
    ./telegram.nix
  ];

  programs.element-desktop.enable = true;
}
