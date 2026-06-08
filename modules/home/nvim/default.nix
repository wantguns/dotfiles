{
  config,
  pkgs,
  lib,
  ...
}:

let
  cfg = config.features;

  fromGitHub =
    {
      owner,
      repo,
      rev,
      sha256 ? lib.fakeSha256,
      doCheck ? false,
    }:
    pkgs.vimUtils.buildVimPlugin {
      pname = "${lib.strings.sanitizeDerivationName repo}";
      version = rev;
      src = pkgs.fetchFromGitHub {
        owner = owner;
        repo = repo;
        rev = rev;
        sha256 = sha256;
      };
      inherit doCheck;
    };

in
lib.mkIf cfg.editors.nvim.enable {
  programs.neovim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;
    vimdiffAlias = true;
    initLua = lib.mkBefore (builtins.readFile ./base.lua);

    extraPackages = with pkgs; [
      (lib.mkIf cfg.editors.nvim.lsp tree-sitter)
    ];

    plugins =
      with pkgs.vimPlugins;
      [
        plenary-nvim
      ]
      ++ lib.optional (cfg.theme == "gruvbox-light") {
        plugin = gruvbox;
        config = "vim.cmd(\"set background=light | set termguicolors | colorscheme gruvbox\")";
      }
      ++ lib.optional (cfg.theme == "moonfly") {
        plugin = fromGitHub {
          owner = "bluz71";
          repo = "vim-moonfly-colors";
          rev = "d11b3d04cc1cb71a778d67a4df73283a5a6d66f4";
          sha256 = "+zUmQWRUNzdUDZBV7xmrA0415/HlagHDi+O9ehdaDN8=";
        };
        config = "vim.cmd(\"colorscheme moonfly\")";
      }

      ++ lib.optional cfg.ai {
        plugin = opencode-nvim;
        config = builtins.readFile ./opencode.lua;
      }

      ++ lib.optionals cfg.editors.nvim.ui [
        vim-fugitive
        which-key-nvim
        {
          plugin = fromGitHub {
            owner = "linrongbin16";
            repo = "gitlinker.nvim";
            rev = "7c1fae10e39fba627a433a0d7126683c79af289f";
            sha256 = "J7WG0xoVI9NKrOrgA7zTdD/Q4gSh+Hhg/wAIh/1RmDA=";
            doCheck = false;
          };
          config = builtins.readFile ./gitlink.lua;
        }
        {
          plugin = gitsigns-nvim;
          config = "require('gitsigns').setup()";
        }
        {
          plugin = lualine-nvim;
          config = builtins.readFile ./lualine.lua;
        }
        {
          plugin = oil-nvim;
          config = builtins.readFile ./oil.lua;
        }
        {
          plugin = telescope-nvim;
          config = builtins.readFile ./telescope.lua;
        }
        {
          plugin = telescope-nvim;
          config = builtins.readFile ./telescope.lua;
        }
      ]

      ++ lib.optionals cfg.editors.nvim.lsp [
        {
          plugin = nvim-treesitter.withAllGrammars;
          config = builtins.readFile ./treesitter.lua;
        }
        {
          plugin = nvim-lspconfig;
          config = builtins.readFile ./lsp.lua;
        }
        {
          plugin = nvim-cmp;
          config = builtins.readFile ./cmp.lua;
        }
        cmp-nvim-lsp
      ]

      ++ lib.optionals cfg.dev.terraform [
        nvim-treesitter-parsers.terraform
      ]

      # Obsidian
      ++ lib.optional cfg.editors.nvim.obsidian {
        plugin = obsidian-nvim;
        config = builtins.readFile ./obsidian.lua;
      };
  };
}
