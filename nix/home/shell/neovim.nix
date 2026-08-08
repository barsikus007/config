{
  lib,
  inputs,
  flakePath,
  ...
}:
{
  imports = [ inputs.nvf.homeManagerModules.default ];

  home.sessionVariables.MANPAGER = "nvim +Man!";
  programs.nvf = {
    enable = true;
    defaultEditor = true;
    #? https://nvf.notashelf.dev/search.html
    settings.vim = {
      #? https://github.com/NotAShelf/nvf/blob/main/configuration.nix
      viAlias = true;
      vimAlias = true;
      # luaConfigRC.basic = builtins.readFile ../.config/nvim/init.lua;
      luaConfigPost = "dofile('${flakePath}/.config/nvim/init.lua')";
      debugMode = {
        enable = false;
        level = 16;
        logFile = "/tmp/nvim.log";
      };

      lsp = {
        enable = lib.mkDefault false;
        formatOnSave = true;
        inlayHints.enable = true;
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
                home-manager.expr = "${nixos.expr}.home-manager.users.type.getSubOptions [] // ${flake}.homeConfigurations.nixd.options";
              };
            };
        };
      };

      # this section does not include a comprehensive list of available language modules;
      # to list all available language module options, please visit the nvf manual
      languages = {
        enableFormat = true;
        enableTreesitter = true;
        enableExtraDiagnostics = true;

        nix = {
          enable = true;
          lsp.servers = [ "nixd" ];
        };
        python = {
          enable = true;
          format.type = [ "ruff" ];
        };
        typescript.enable = true;
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

      binds.whichKey.enable = true;

      #? <leader>? for keymap
      #? <leader>f* for file picker
      fzf-lua.enable = true;
      #! unlike telescope's, the fzf-lua module ships no mappings option, so its old
      #! <leader>f... layout is rebuilt by hand; going through the :FzfLua command
      #! rather than require("fzf-lua") is what makes lz.n load the plugin
      keymaps =
        lib.mapAttrsToList
          (suffix: picker: {
            key = "<leader>${suffix}";
            mode = "n";
            desc = "FzfLua ${picker}";
            action = "<cmd>FzfLua ${picker}<CR>";
          })
          {
            "?" = "keymaps";
            ff = "files";
            fg = "live_grep";
            fb = "buffers";
            fh = "helptags";
            fr = "resume";
            fo = "oldfiles";
            fs = "treesitter";
            fld = "diagnostics_document";
            flr = "lsp_references";
            fvf = "git_files";
            fvb = "git_branches";
            fvs = "git_status";
          }
        ++ [
          #! todo-comments only gets its <leader>tds when telescope is enabled, and
          #! nvf never offers the :TodoFzfLua variant the plugin also ships
          {
            key = "<leader>tds";
            mode = "n";
            desc = "Open Todo-s in fzf-lua";
            action = "<cmd>TodoFzfLua<CR>";
          }
        ];

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
        #? <leader>- at current file, <leader>cw at cwd, <c-up> resume last session
        yazi-nvim = {
          enable = true;
          #! <c-s>/<c-g> inside yazi grep the hovered dir through this backend,
          #! and the plugin defaults it to telescope
          setupOpts.integrations = {
            grep_in_directory = "fzf-lua";
            grep_in_selected_files = "fzf-lua";
          };
        };
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
        # (gb/gbc)
        comment-nvim = {
          enable = true;
          mappings = {
            toggleCurrentLine = null; # gcc -> native
            toggleOpLeaderLine = null; # gc -> native
            toggleSelectedLine = null; # visual gc -> native
          };
        };
      };
    };
  };
}
