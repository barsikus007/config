let
  lib = (import <nixpkgs> { }).lib;

  tags = [
    "TODO"
    "essential"
    "pack"
    "theme"
    "github"
    "javascript"
    "python"
    "nix"
    "devops"
    "generic language"
    "docs"
    "disabled"
  ];

  extensions = {
    "christian-kohler.path-intellisense" = [
      "TODO" # TODO: check: which langages affected altrought nix
      "essential"
    ];
    "mechatroner.rainbow-csv" = [
      "essential"
      "theme"
    ];
    "oderwat.indent-rainbow" = [
      "essential"
      "theme"
    ];
    "vscode-icons-team.vscode-icons" = [
      "essential"
      "theme"
    ];
    "ahmadawais.shades-of-purple" = [
      "essential"
      "theme"
    ];
    "wicked-labs.wvsc-serendipity" = [ "theme" ];
    "enkia.tokyo-night" = [ "theme" ];
    "mgwg.light-pink-theme" = [ "theme" ];
    "akamud.vscode-theme-onedark" = [ "theme" ];

    "aaron-bond.better-comments" = [ "essential" ];
    "arthurlobo.easy-codesnap" = [
      "TODO" # TODO: setup; decide if need
      "essential"
    ];
    "dotjoshjohnson.xml" = [
      "TODO" # TODO: now this is native?
      "essential"
    ];
    "editorconfig.editorconfig" = [ "essential" ];
    "timonwong.shellcheck" = [ "essential" ];
    "foxundermoon.shell-format" = [ "essential" ];
    "jock.svg" = [
      "TODO" # TODO: now this is native?
      "essential"
    ];
    "kisstkondoros.vscode-gutter-preview" = [
      "TODO" # TODO: now this is native?
      "essential"
    ];
    "mikestead.dotenv" = [
      "TODO" # TODO: now this is native?
      "essential"
    ];
    "moshfeu.compare-folders" = [
      "TODO" # TODO: now this is native?
      "essential"
    ];
    "ms-vscode.hexeditor" = [
      "TODO" # TODO: now this is native?
      "essential"
    ];
    "qwtel.sqlite-viewer" = [ "essential" ];
    "ruschaaf.extended-embedded-languages" = [
      "TODO" # TODO: comment-syntax
      "essential"
    ];
    "semanticdiff.semanticdiff" = [ "essential" ];
    "sourcery.sourcery" = [
      "TODO"
      "essential"
    ];

    "tamasfe.even-better-toml" = [
      "TODO" # TODO: now this is native?
      "essential"
      "generic language"
    ];
    "tomoki1207.pdf" = [
      "TODO" # TODO: now this is native?
      "essential"
      "generic language"
    ];

    "eamodio.gitlens" = [ "github" ];
    "github.vscode-github-actions" = [ "github" ];
    "github.vscode-pull-request-github" = [ "github" ];
    "jamitech.simply-blame" = [
      "TODO" # TODO: merge with gitlens or fork
      "github"
    ];
    "bierner.github-markdown-preview" = [
      "pack"
      "docs"
      "github"
    ];
    "bierner.markdown-checkbox" = [ "docs" ];
    "bierner.markdown-emoji" = [ "docs" ];
    "bierner.markdown-footnotes" = [ "docs" ];
    "bierner.markdown-mermaid" = [ "docs" ];
    "bierner.markdown-preview-github-styles" = [ "docs" ];
    "bierner.markdown-yaml-preamble" = [ "docs" ];
    "davidanson.vscode-markdownlint" = [ "docs" ];
    "yzhang.markdown-all-in-one" = [ "docs" ];

    "charliermarsh.ruff" = [ "python" ];
    "cstrap.python-snippets" = [ "python" ];
    "kevinrose.vsc-python-indent" = [
      "TODO" # TODO: now this is native?
      "python"
    ];
    "mgesbert.indent-nested-dictionary" = [
      "TODO" # TODO: now this is native?
      "python"
    ];
    "mihaicosma.quick-python-printf" = [ "python" ];
    "ms-python.debugpy" = [ "python" ];
    "ms-python.mypy-type-checker" = [ "python" ];
    "ms-python.pylint" = [ "python" ];
    "ms-python.python" = [ "python" ];
    "ms-python.vscode-pylance" = [ "python" ];
    "ms-python.vscode-python-envs" = [ "python" ];
    "twixes.pypi-assistant" = [ "python" ];

    "bierner.comment-tagged-templates" = [
      "TODO" # TODO: comment-syntax
      "javascript"
    ];
    "ahadcove.js-quick-console" = [ "javascript" ];
    "dbaeumer.vscode-eslint" = [
      "TODO" # TODO: prettier-eslint
      "javascript"
    ];
    "esbenp.prettier-vscode" = [
      "TODO" # TODO: prettier-eslint
      "javascript"
    ];
    "rvest.vs-code-prettier-eslint" = [
      "TODO" # TODO: prettier-eslint
      "javascript"
    ];
    "mgmcdermott.vscode-language-babel" = [
      "TODO" # TODO: now this is native?
      "javascript"
    ];
    "ms-vscode.live-server" = [
      "TODO" # TODO: now this is native?
      "javascript"
    ];
    "mxsdev.typescript-explorer" = [ "javascript" ];
    "oven.bun-vscode" = [
      "TODO" # TODO: now this is native?
      "javascript"
    ];
    "pranaygp.vscode-css-peek" = [
      "TODO" # TODO: css: now this is native?
      "javascript"
    ];
    "syler.sass-indented" = [
      "TODO" # TODO: css: now this is native?
      "javascript"
    ];
    "qufiwefefwoyn.inline-sql-syntax" = [
      "TODO" # TODO: comment-syntax
      "python"
      "javascript"
    ];
    "styled-components.vscode-styled-components" = [ "javascript" ];
    "unifiedjs.vscode-mdx" = [
      "TODO"
      "javascript"
    ];
    "vincaslt.highlight-matching-tag" = [
      "TODO" # TODO: now this is native?
      "javascript"
    ];
    "wix.vscode-import-cost" = [ "javascript" ];
    "yoavbls.pretty-ts-errors" = [ "javascript" ];

    "coopermaruyama.nix-embedded-languages" = [ "nix" ];
    "jnoortheen.nix-ide" = [ "nix" ];
    "mkhl.direnv" = [ "nix" ];

    "docker.docker" = [ "devops" ];
    "exiasr.hadolint" = [ "devops" ];
    "ms-vscode-remote.vscode-remote-extensionpack" = [
      "pack"
      "devops"
    ];
    "ms-azuretools.vscode-containers" = [ "devops" ];
    "ms-vscode-remote.remote-containers" = [ "devops" ];
    "ms-vscode-remote.remote-ssh" = [ "devops" ];
    "ms-vscode-remote.remote-ssh-edit" = [ "devops" ];
    "ms-vscode-remote.remote-wsl" = [ "devops" ];
    "ms-vscode.remote-explorer" = [ "devops" ];
    "ms-vscode.remote-server" = [ "devops" ];
    "yy0931.save-as-root" = [ "devops" ];

    "grafana.grafana-alloy" = [ "generic language" ];
    "kdl-org.kdl" = [ "generic language" ];
    "mattn.lisp" = [ "generic language" ];
    "myriad-dreamin.tinymist" = [ "generic language" ];
    "ahmadalli.vscode-nginx-conf" = [ "generic language" ];
    "raynigon.nginx-formatter" = [ "generic language" ];
    "redhat.vscode-yaml" = [
      "TODO" # TODO: conflict with docker
      "generic language"
    ];
    "rust-lang.rust-analyzer" = [ "generic language" ];
    "sumneko.lua" = [ "generic language" ];

    "google.gemini-cli-vscode-ide-companion" = [ "TODO" ];
    "ibm.output-colorizer" = [
      "TODO" # TODO: setup; decide if need
    ];

    "astral-sh.ty" = [
      "TODO" # TODO: is alt to mypy?
      "disabled"
      "python"
    ];
    "mtxr.sqltools" = [ "disabled" ];
    "mtxr.sqltools-driver-pg" = [ "disabled" ];
    "mtxr.sqltools-driver-sqlite" = [ "disabled" ];
    "figma.figma-vscode-extension" = [ "disabled" ];
    "ms-vsliveshare.vsliveshare" = [ "disabled" ];
    "christian-kohler.npm-intellisense" = [
      "TODO" # TODO: now this is native?
      "disabled"
    ];
    "streetsidesoftware.code-spell-checker" = [ "disabled" ];
    "streetsidesoftware.code-spell-checker-russian" = [ "disabled" ];
  };

  usedTags = lib.unique (lib.flatten (lib.attrValues extensions));
  invalidTags = lib.subtractLists tags usedTags;

  checkedExtensions =
    assert lib.assertMsg (invalidTags == [ ]) "Unknown tags: ${builtins.toJSON invalidTags}";
    extensions;
in
builtins.attrNames checkedExtensions
