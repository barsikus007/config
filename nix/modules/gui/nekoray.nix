{
  pkgs,
  ...
}:
let
  repo =
    # TODO rename file after PR accepted
    # (builtins.getFlake "github:TomaSajt/nixpkgs/7f01041c58ffddc0acab9723dc9c2dced6fbd8cd").outPath;
    (builtins.getFlake "github:NixOS/nixpkgs/8aaebd41e5277081bda6ab5509f47aff1c2c3795").outPath;
in
{
  imports = [
    "${repo}/nixos/modules/programs/throne.nix"
  ];
  disabledModules = [
    "programs/nekoray.nix"
  ];
  programs.throne = {
    #? https://github.com/throneproj/Throne/issues/720#issuecomment-3223685757
    #! Settings -> Basic settings -> Core -> Core Options -> Underlying DNS: `tcp://1.0.0.1`
    enable = true;
    # package = "${repo}/pkgs/by-name/th/throne/package.nix";
    package = (
      pkgs.callPackage "${repo}/pkgs/by-name/th/throne/package.nix" {
        protorpc = pkgs.callPackage "${repo}/pkgs/by-name/pr/protorpc/package.nix" { };
      }
    );
    tunMode = {
      enable = true;
      # TODO is this needed? reboot autostart related?
      # setuid = true;
    };
  };
}
