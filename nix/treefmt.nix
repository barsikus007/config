{ pkgs }:
let
  inherit (pkgs) lib;
  toml = (pkgs.formats.toml { }).generate;

  statixConfig = toml "statix.toml" {
    disabled = [
      # "bool_comparison"
      # "empty_let_in"
      "manual_inherit"
      "manual_inherit_from"
      # "legacy_let_syntax"
      "collapsible_let_in"
      # "eta_reduction"
      "useless_parens"
      # "empty_pattern"
      # "redundant_pattern_bind"
      # "unquoted_uri"
      # "empty_inherit"
      # "deprecated_to_path"
      # "bool_simplification"
      "useless_has_attr"
      # "repeated_keys"
      "empty_list_concat"
    ];
  };

  pedantixConfig = toml "pedantix.toml" {
    formatter = "nixfmt";
    args = {
      sort = false; # TODO: remove that
      #? it follows my older sort logic
      first = [
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
      statix check --config ${statixConfig} ${excludeArgs "--ignore"} "$target" || status=1
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
        options = [
          "--edit"
          "--no-lambda-arg" # TODO: remove that
        ];
      };
      #? https://github.com/molybdenumsoftware/statix
      statix = {
        inherit includes;
        command = "statix";
        options = [
          "fix"
          "--config"
          "${statixConfig}"
        ];
        no-positional-arg-support = true;
      };
      #? https://github.com/Swarsel/pedantix
      pedantix = {
        inherit includes;
        command = "pedantix";
        options = [
          "--config"
          "${pedantixConfig}"
        ];
        priority = 1;
      };
    };
  };
}
// {
  inherit nix-lint;
}
