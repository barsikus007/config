{ config, pkgs, ... }:

{
  home = {
    sessionVariables = {
      MANPAGER = "${pkgs.neovim}/bin/nvim +Man!";
      # TODO: until nvf became light
      # MANPAGER = "nvim --clean +Man!";
    };
  };
  programs.neovim = {
    enable = false;
    defaultEditor = false;
    viAlias = false;
    vimAlias = false;
  };
  programs.nvf = {
    enable = true;
    defaultEditor = true;
    settings.vim = {
      # https://github.com/NotAShelf/nvf/blob/main/configuration.nix
      viAlias = true;
      vimAlias = true;
      options = {
        # fix indents
        autoindent = true;
        smartindent = true;
        smarttab = true;
        expandtab = true;
        tabstop = 2;
        softtabstop = 2;
        shiftwidth = 2;
      };
      luaConfigRC.basic = builtins.readFile ../.config/nvim/init.lua;
      debugMode = {
        enable = false;
        level = 16;
        logFile = "/tmp/nvim.log";
      };

      lsp = {
        formatOnSave = true;
        # https://github.com/onsails/lspkind.nvim
        lspkind.enable = false;
        # https://github.com/kosayoda/nvim-lightbulb
        lightbulb.enable = true;
        trouble.enable = true;
        lspSignature.enable = true;
      };

      # This section does not include a comprehensive list of available language modules.
      # To list all available language module options, please visit the nvf manual.
      languages = {
        enableLSP = true;
        enableFormat = true;
        enableTreesitter = true;
        enableExtraDiagnostics = true;

        # Languages that will be supported in default and maximal configurations.
        nix.enable = true;
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
          theme = "catppuccin";
        };
      };

      theme = {
        enable = true;
        name = "catppuccin";
        style = "mocha";
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
        nvimBufferline.enable = true;
      };

      treesitter.context.enable = true;

      binds = {
        whichKey.enable = true;
        cheatsheet.enable = true;
      };

      telescope.enable = true;

      git = {
        enable = true;
        gitsigns.enable = true;
        gitsigns.codeActions.enable = false; # throws an annoying debug message
      };

      minimap = {
        minimap-vim.enable = false;
      };

      dashboard = {
        dashboard-nvim.enable = false;
      };

      notify = {
        nvim-notify.enable = true;
      };

      utility = {
        ccc.enable = false;
        diffview-nvim.enable = true;

        motion = {
          hop.enable = true;
          leap.enable = true;
        };
      };

      notes = {
        todo-comments.enable = true;
      };

      terminal = {
        toggleterm = {
          enable = true;
          lazygit.enable = true;
        };
      };

      ui = {
        borders.enable = true;
        noice.enable = true;
        colorizer.enable = true;
        modes-nvim.enable = false; # the theme looks terrible with catppuccin
        illuminate.enable = true;
        smartcolumn = {
          enable = true;
          setupOpts.custom_colorcolumn = {
            # this is a freeform module, it's `buftype = int;` for configuring column position
            nix = "110";
            ruby = "120";
            java = "130";
            go = ["90" "130"];
          };
        };
        fastaction.enable = true;
      };

      # https://github.com/numToStr/Comment.nvim
      comments = {
        comment-nvim.enable = true;
      };
    };
  };
}
