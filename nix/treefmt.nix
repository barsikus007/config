{ pkgs }:
let
  inherit (pkgs) lib;
  toml = (pkgs.formats.toml { }).generate;

  pedantixConfig = toml "pedantix.toml" {
    formatter = "nixfmt";
    args = {
      sort = true; # TODO: remove that
      #? it follows my older sort logic
      first = [
        "_class"
        "lib"
        "pkgs"
        "self"
        "config"
        "inputs"
        "username"
        "modulesPath"
        "width"
        "height"
      ];
      last = [
        "<defaulted>"
        "..."
      ];
    };
    attrs.sort = false;
  };

  includes = [ "*.nix" ];
  excludes = [
    "**/.direnv/*"
    "**/packages/windows/*" # TODO: remove that
    "**/modules/system/activation/*" # TODO: remove that
  ];
  nixpkgs-packages = [ "**/packages/**.nix" ];
  #! the linters have to skip exactly what `nix fmt` skips - deadnix, statix and fd all take the
  #! same globs, only under different flag names
  excludeArgs =
    flag:
    lib.escapeShellArgs (
      lib.concatMap (glob: [
        flag
        glob
      ]) excludes
    );
  #! treefmt has no dry-run, `nix fmt` always writes - this only reports
  #! deadnix and pedantix are covered by `.check` too, since they rewrite and a diff shows up there;
  #! `statix check` is the part nothing else sees - statix fix repairs less than check finds
  nix-lint = pkgs.writeShellApplication {
    name = "nix-lint";
    runtimeInputs = with pkgs; [
      fd
      statix
      deadnix
      pedantix
      nixfmt
    ];
    text = /* shell */ ''
      target="''${1:-.}"
      status=0

      deadnix --fail ${excludeArgs "--exclude"} "$target" || status=1
      #! statix reads statix.toml from cwd only, so the path is baked in
      statix check ${excludeArgs "--ignore"} "$target" || status=1
      fd --extension nix . "$target" ${excludeArgs "--exclude"} \
        --exec-batch pedantix --check --config ${pedantixConfig} || status=1

      exit "$status"
    '';
  };
in
pkgs.treefmt.withConfig {
  runtimeInputs = with pkgs; [
    deadnix
    statix
    pedantix
    nixfmt
  ];
  settings = {
    on-unmatched = "info";
    inherit excludes;
    formatter = {
      #? https://github.com/astro/deadnix
      deadnix = {
        inherit includes;
        command = "deadnix";
        options = [ "--edit" ];
      };
      #? https://github.com/molybdenumsoftware/statix
      statix = {
        inherit includes;
        command = "statix";
        options = [ "fix" ];
        no-positional-arg-support = true;
      };
      #? https://github.com/Swarsel/pedantix
      pedantix = {
        inherit includes;
        excludes = nixpkgs-packages;
        command = "pedantix";
        options = [
          "--config"
          pedantixConfig
        ];
        priority = 1;
      };
      pedantix-nixpkgs-package = {
        excludes = [ "**" ]; # TODO: remove that
        includes = nixpkgs-packages;
        command = "pedantix";
        options =
          let
            paths = [
              "srcs"
              "pkgsList"
              "fetchDebs"
            ];
          in
          [
            "--config"
            (toml "pedantix.toml" {
              preset = "nixpkgs-package";
              overrides = map (path: {
                path = "**.${path}";
                attrs.first = [
                  "name"
                  "url"
                  "owner"
                  "repo"
                  "rev"
                  "tag"
                  "hash"
                  "sha256"
                  "fetchSubmodules"
                ];
              }) paths;
            })
          ];
        priority = 1;
      };
    };
  };
}
// {
  inherit nix-lint;
}
