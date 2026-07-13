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
    initLua = lib.mkMerge [
      (lib.mkBefore (builtins.readFile ./base.lua))
      (lib.mkIf cfg.editors.nvim.ui (builtins.readFile ./fugitive.lua))
      (lib.mkIf cfg.editors.nvim.lsp (builtins.readFile ./lsp/base.lua))
      (lib.mkIf (cfg.editors.nvim.lsp && cfg.dev.go) (builtins.readFile ./lsp/go.lua))
      (lib.mkIf (cfg.editors.nvim.lsp && cfg.dev.rust) (builtins.readFile ./lsp/rust.lua))
      (lib.mkIf (cfg.editors.nvim.lsp && cfg.dev.python) (builtins.readFile ./lsp/python.lua))
      (lib.mkIf (cfg.editors.nvim.lsp && cfg.dev.terraform) (builtins.readFile ./lsp/terraform.lua))
      (lib.mkIf (cfg.editors.nvim.lsp && cfg.dev.nodejs) (builtins.readFile ./lsp/nodejs.lua))
      (lib.mkIf (cfg.editors.nvim.lsp && cfg.dev.lua) (builtins.readFile ./lsp/lua.lua))
      (lib.mkIf (cfg.editors.nvim.lsp && cfg.dev.zig) (builtins.readFile ./lsp/zig.lua))
      (lib.mkIf (cfg.editors.nvim.lsp && cfg.dev.bash) (builtins.readFile ./lsp/bash.lua))
    ];

    extraPackages = with pkgs; [
      (lib.mkIf cfg.editors.nvim.lsp tree-sitter)
    ];

    plugins =
      with pkgs.vimPlugins;
      [
        plenary-nvim
        vim-sleuth
        {
          plugin = auto-session;
          config = "require('auto-session').setup({ suppressed_dirs = { '~/', '~/Downloads', '/' } })";
        }
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

      ++ lib.optional cfg.ai.opencode {
        plugin = opencode-nvim;
        config = builtins.readFile ./opencode.lua;
      }

      ++ lib.optionals cfg.editors.nvim.ui [
        vim-fugitive
        vim-rhubarb
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
      ]

      ++ lib.optionals cfg.editors.nvim.lsp [
        {
          plugin = nvim-treesitter.withAllGrammars;
          config = builtins.readFile ./treesitter.lua;
        }
        {
          plugin = nvim-treesitter-textobjects;
          config = builtins.readFile ./ts-textobjects.lua;
        }
        {
          plugin = nvim-treesitter-context;
          config = builtins.readFile ./ts-context.lua;
        }
        {
          plugin = blink-cmp;
          config = builtins.readFile ./blink.lua;
        }
      ]

      ++ lib.optional cfg.editors.nvim.obsidian {
        plugin = obsidian-nvim;
        config = builtins.readFile ./obsidian.lua;
      };
  };
}
