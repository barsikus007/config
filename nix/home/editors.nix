{ lib, flakePath, ... }:
{
  #! imports = [ inputs.nvf.homeManagerModules.default ];
  home.sessionVariables.MANPAGER = "nvim +Man!";
  programs.nvf = {
    enable = true;
    defaultEditor = true;
    #? https://nvf.notashelf.dev/search.html
    settings.vim = {
      #? https://github.com/NotAShelf/nvf/blob/main/configuration.nix
      viAlias = true;
      vimAlias = true;
      keymaps = [
        {
          key = "<leader>?";
          mode = "n";
          silent = true;
          action = ":Cheatsheet<CR>";
        }
      ];
      # luaConfigRC.basic = builtins.readFile ../.config/nvim/init.lua;
      luaConfigPost = "dofile('${flakePath}/.config/nvim/init.lua')";
      debugMode = {
        enable = false;
        level = 16;
        logFile = "/tmp/nvim.log";
      };

      lsp = {
        enable = false;
        formatOnSave = true;
        inlayHints.enable = true;
        mappings.goToDefinition = "gd";
        # https://github.com/onsails/lspkind.nvim
        lspkind.enable = false;
        # https://github.com/kosayoda/nvim-lightbulb
        lightbulb.enable = true;
        # https://github.com/folke/trouble.nvim
        trouble.enable = true;
        # https://github.com/ray-x/lsp_signature.nvim
        lspSignature.enable = true;

        servers = {
          nixd.init_options =
            let
              flake = "(builtins.getFlake ''${flakePath}'')";
            in
            {
              # TODO: home-manager-module
              nixpkgs.expr = "import ''${flakePath}/nixpkgs.nix'' { system = ''x86_64-linux''; inputs = ${flake}.inputs; }";
              options = rec {
                nixos.expr = "${flake}.nixosConfigurations.ROG14.options";
                # home-manager.expr = "${flake}.homeConfigurations.${username}.options";
                home-manager.expr = "${nixos.expr}.home-manager.users.type.getSubOptions []";
              };
            };
        };
      };

      # This section does not include a comprehensive list of available language modules.
      # To list all available language module options, please visit the nvf manual.
      languages = {
        enableFormat = true;
        enableTreesitter = true;
        enableExtraDiagnostics = true;

        lua = {
          enable = true;
        };
        nix = {
          enable = true;
          lsp.servers = [ "nixd" ];
        };
        python = {
          enable = true;
          format.type = [ "ruff" ];
        };
        ts.enable = true;
        css.enable = true;
      };

      visuals = {
        nvim-web-devicons.enable = true;
        nvim-cursorline.enable = true;
        cinnamon-nvim.enable = true;
        fidget-nvim.enable = true;

        highlight-undo.enable = true;
        indent-blankline.enable = true;
      };

      statusline = {
        lualine = {
          enable = true;
          theme = lib.mkDefault "catppuccin";
        };
      };

      theme = {
        enable = true;
        # TODO remove it at all ?
        name = lib.mkOverride 999 "catppuccin";
        style = lib.mkOverride 999 "mocha";
        transparent = false;
      };

      autopairs.nvim-autopairs.enable = true;

      autocomplete.nvim-cmp.enable = true;
      snippets.luasnip.enable = true;

      filetree = {
        neo-tree = {
          enable = true;
        };
      };

      tabline = {
        # https://github.com/akinsho/bufferline.nvim
        nvimBufferline.enable = true;
      };

      treesitter.context.enable = true;

      binds = {
        whichKey.enable = true;
        # https://github.com/sudormrfbin/cheatsheet.nvim
        # <leader>?
        cheatsheet.enable = true;
      };

      telescope.enable = true;

      git = {
        enable = true;
        gitsigns.enable = true;
        gitsigns.codeActions.enable = false; # throws an annoying debug message
      };

      dashboard = {
        dashboard-nvim.enable = true;
      };

      notify = {
        nvim-notify.enable = true;
      };

      utility = {
        diffview-nvim.enable = true;
      };

      notes = {
        todo-comments.enable = true;
      };

      terminal = {
        toggleterm = {
          # https://github.com/akinsho/toggleterm.nvim
          # <c-t>
          enable = true;
          # <leader>gg
          lazygit.enable = true;
        };
      };

      ui = {
        borders.enable = true;
        noice.enable = true;
        colorizer.enable = true;
        illuminate.enable = true;
        smartcolumn = {
          enable = true;
        };
        # https://github.com/Chaitanyabsprip/fastaction.nvim
        fastaction.enable = true;
      };

      comments = {
        # https://github.com/numToStr/Comment.nvim
        # gcc
        # gbc
        comment-nvim.enable = true;
      };
    };
  };
}
