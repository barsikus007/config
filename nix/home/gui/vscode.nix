{ pkgs, unstable, ...}: {
  programs.vscode = {
    enable = true;
    package = unstable.vscodium;
    # enableUpdateCheck = false;
    extensions = with pkgs.vscode-extensions; [
      yzhang.markdown-all-in-one
      jnoortheen.nix-ide
    ];
  };
}
