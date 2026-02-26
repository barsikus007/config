let
  lib = (import <nixpkgs> { }).lib;

  tags = [
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
    "mikestead.dotenv" = [ "theme" ]; # ? vscode have native highlight now, but I prefer this color scheme
    "ibm.output-colorizer" = [ "theme" ]; # ? vscode have native highlight now, but I prefer this color scheme
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

    "christian-kohler.path-intellisense" = [ "essential" ];
    "aaron-bond.better-comments" = [ "essential" ];
    "arthurlobo.easy-codesnap" = [ "essential" ]; # TODO: setup; decide if need
    "editorconfig.editorconfig" = [ "essential" ];
    "kisstkondoros.vscode-gutter-preview" = [ "essential" ];
    "moshfeu.compare-folders" = [ "essential" ];
    "ms-vscode.hexeditor" = [ "essential" ];
    "qwtel.sqlite-viewer" = [ "essential" ];
    "mgesbert.indent-nested-dictionary" = [ "essential" ]; # ? will format even broken json
    "ruschaaf.extended-embedded-languages" = [ "essential" ]; # TODO: comment-syntax
    "semanticdiff.semanticdiff" = [ "essential" ];
    "sourcery.sourcery" = [ "essential" ]; # ? ai
    "google.gemini-cli-vscode-ide-companion" = [ "essential" ]; # ? ai

    "timonwong.shellcheck" = [
      "essential"
      "generic language"
    ];
    "foxundermoon.shell-format" = [
      "essential"
      "generic language"
    ];
    "tamasfe.even-better-toml" = [
      "essential"
      "generic language"
    ];
    "tomoki1207.pdf" = [
      "essential"
      "generic language"
    ];

    "eamodio.gitlens" = [ "github" ];
    "github.vscode-github-actions" = [ "github" ];
    "github.vscode-pull-request-github" = [ "github" ];
    "jamitech.simply-blame" = [ "github" ]; # TODO: merge with gitlens or fork
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
    "mihaicosma.quick-python-printf" = [ "python" ];
    "ms-python.debugpy" = [ "python" ];
    "ms-python.mypy-type-checker" = [ "python" ];
    "ms-python.pylint" = [ "python" ];
    "ms-python.python" = [ "python" ];
    "ms-python.vscode-pylance" = [ "python" ];
    "ms-python.vscode-python-envs" = [ "python" ];
    "twixes.pypi-assistant" = [ "python" ];

    "jock.svg" = [ "javascript" ];
    "ms-vscode.live-server" = [ "javascript" ]; # ? html preview
    "pranaygp.vscode-css-peek" = [ "javascript" ]; # ? ctrl+click classes in html
    "oven.bun-vscode" = [ "javascript" ]; # ? instead of default node.js tools
    "wix.vscode-import-cost" = [ "javascript" ]; # ? or use https://phobia.vercel.app/
    "ahadcove.js-quick-console" = [ "javascript" ]; # ? ctrl+shift+l
    "mgmcdermott.vscode-language-babel" = [ "javascript" ]; # ? mainly for graphql
    "styled-components.vscode-styled-components" = [ "javascript" ]; # ? styled lsp
    "unifiedjs.vscode-mdx" = [ "javascript" ]; # ? mdx lsp
    "yoavbls.pretty-ts-errors" = [ "javascript" ]; # ? typescript
    "mxsdev.typescript-explorer" = [ "javascript" ]; # ? typescript
    "qufiwefefwoyn.inline-sql-syntax" = [
      "python"
      "javascript"
    ]; # TODO: comment-syntax
    "bierner.comment-tagged-templates" = [ "javascript" ]; # TODO: comment-syntax
    "dbaeumer.vscode-eslint" = [ "javascript" ]; # TODO: prettier-eslint
    "esbenp.prettier-vscode" = [ "javascript" ]; # TODO: prettier-eslint
    "rvest.vs-code-prettier-eslint" = [ "javascript" ]; # TODO: prettier-eslint

    "coopermaruyama.nix-embedded-languages" = [ "nix" ];
    "jnoortheen.nix-ide" = [ "nix" ];
    "mkhl.direnv" = [ "nix" ];

    "docker.docker" = [ "devops" ];
    "exiasr.hadolint" = [ "devops" ];
    "ms-vscode-remote.vscode-remote-extensionpack" = [
      "pack"
      "devops"
    ];
    "ms-vscode-remote.remote-containers" = [ "devops" ]; # ? pack above
    "ms-vscode-remote.remote-ssh" = [ "devops" ]; # ? pack above
    "ms-vscode-remote.remote-wsl" = [ "devops" ]; # ? pack above
    "ms-vscode.remote-server" = [ "devops" ]; # ? pack above
    "ms-azuretools.vscode-containers" = [ "devops" ];
    "ms-vscode-remote.remote-ssh-edit" = [ "devops" ];
    "ms-vscode.remote-explorer" = [ "devops" ];
    "yy0931.save-as-root" = [ "devops" ];

    "grafana.grafana-alloy" = [ "generic language" ];
    "mattn.lisp" = [ "generic language" ];
    "myriad-dreamin.tinymist" = [ "generic language" ];
    "ahmadalli.vscode-nginx-conf" = [ "generic language" ];
    "raynigon.nginx-formatter" = [ "generic language" ];
    "kdl-org.kdl" = [ "generic language" ];
    "redhat.vscode-xml" = [ "generic language" ];
    "redhat.vscode-yaml" = [ "generic language" ];
    "rust-lang.rust-analyzer" = [ "generic language" ];
    "sumneko.lua" = [ "generic language" ];

    "astral-sh.ty" = [
      "disabled"
      "python"
    ]; # TODO: is alt to mypy now?
    "mtxr.sqltools" = [ "disabled" ];
    "mtxr.sqltools-driver-pg" = [ "disabled" ];
    "mtxr.sqltools-driver-sqlite" = [ "disabled" ];
    "figma.figma-vscode-extension" = [ "disabled" ];
    "ms-vsliveshare.vsliveshare" = [ "disabled" ];
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
