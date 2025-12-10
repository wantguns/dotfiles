{ config, pkgs, lib, ... }:

let
  cfg = config.features;

  toLua = str: ''

    lua << EOF
    ${str}
    EOF'';
  toLuaFile = file: ''

    lua << EOF
    ${builtins.readFile file}
    EOF'';

  fromGitHub = { owner, repo, rev, sha256 ? lib.fakeSha256, doCheck ? false }:
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

  fakeVimPlugin = pkgs.runCommand "fakeVimPlugin" { } "mkdir $out";
in {
  config = lib.mkMerge [
    {
      home = {
        stateVersion = "24.11";
        packages = with pkgs; [
          (lib.mkIf cfg.alacritty nerd-fonts.iosevka-term)
          (iosevka-bin.override { variant = "SS15"; })
          ripgrep
        ];
      };

      fonts.fontconfig.enable = true;
      programs.home-manager.enable = true;
    }

    (lib.mkIf cfg.editors.nvim.enable {
      programs.neovim = {
        enable = true;
        defaultEditor = true;
        viAlias = true;
        vimAlias = true;
        vimdiffAlias = true;

        plugins = with pkgs.vimPlugins;
          [
            {
              plugin = fakeVimPlugin;
              config = toLuaFile ./nvim/base.lua;
            }
            plenary-nvim
          ] 
          ++ lib.optional (cfg.theme == "gruvbox-light") {
              plugin = gruvbox;
              config = "set background=light | set termguicolors | colorscheme gruvbox";
            }
          ++ lib.optional (cfg.theme == "moonfly")
            { 
              plugin = fromGitHub {
                owner = "bluz71";
                repo = "vim-moonfly-colors";
                rev = "b2c58a0c6eb3ee091d5cc13b8f4f6e6fba8a9c7a";
                sha256 = "Q59tUqcv7I36XrCd3L6D/ICWbf9FvPMeSekrVib6wBs=";
              };
              config = "colorscheme moonfly";
            }

          ++ lib.optional cfg.ai {
              plugin = opencode-nvim;
              config = toLuaFile ./nvim/opencode.lua;
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
              config = toLuaFile ./nvim/gitlink.lua;
            }
            {
              plugin = gitsigns-nvim;
              config = toLua "require('gitsigns').setup()";
            }
            {
              plugin = lualine-nvim;
              config = toLuaFile ./nvim/lualine.lua;
            }
            {
              plugin = oil-nvim;
              config = toLuaFile ./nvim/oil.lua;
            }
            {
              plugin = telescope-nvim;
              config = toLuaFile ./nvim/telescope.lua;
            }
            {
              plugin = telescope-nvim;
              config = toLuaFile ./nvim/telescope.lua;
            }
          ]

          ++ lib.optionals cfg.editors.nvim.lsp [
            {
              plugin = nvim-treesitter.withAllGrammars;
              config = toLuaFile ./nvim/treesitter.lua;
            }
            {
              plugin = nvim-lspconfig;
              config = toLuaFile ./nvim/lsp.lua;
            }
            {
              plugin = nvim-cmp;
              config = toLuaFile ./nvim/cmp.lua;
            }
            cmp-nvim-lsp
          ]

          ++ lib.optionals cfg.dev.terraform [
            nvim-treesitter-parsers.terraform
          ]

          # Obsidian
          ++ lib.optional cfg.editors.nvim.obsidian {
            plugin = obsidian-nvim;
            config = toLuaFile ./nvim/obsidian.lua;
          };

        extraPackages = with pkgs; [
          (lib.mkIf cfg.dev.lua lua-language-server)
          (lib.mkIf cfg.dev.go gopls)
          (lib.mkIf cfg.dev.go golangci-lint-langserver)
          (lib.mkIf cfg.dev.python pyright)
          (lib.mkIf cfg.dev.terraform terraform-ls)
          (lib.mkIf cfg.dev.nodejs typescript-language-server)
          (lib.mkIf cfg.dev.nodejs typescript)
          (lib.mkIf cfg.dev.zig zls)
        ];
      };
    })

    (lib.mkIf cfg.shell.zsh.enable {
      programs.zsh = {
        enable = true;
        syntaxHighlighting.enable = true;
        autosuggestion.enable = true;
        enableCompletion = true;
        defaultKeymap = "viins";

        completionInit = "autoload -U compinit && compinit -u";

        history = {
          append = true;
          extended = true;
          size = 10000;
          save = 1000000;
        };

        initContent = builtins.readFile ./zsh/zshrc;

        plugins = lib.optional cfg.shell.zsh.powerlevel10k {
          name = "zsh-powerlevel10k";
          src = "${pkgs.zsh-powerlevel10k}/share/zsh-powerlevel10k/";
          file = "powerlevel10k.zsh-theme";
        };
      };
    })

    (lib.mkIf (cfg.shell.zsh.enable && cfg.shell.zsh.powerlevel10k) {
      home.file.".p10k.zsh".source = ./zsh/p10k.zsh;
    })

    (lib.mkIf cfg.fzf { programs.fzf.enable = true; })

    (lib.mkIf cfg.tmux {
      programs.tmux = {
        enable = true;
        extraConfig = builtins.readFile ./tmux/tmux.conf;
      };
    })

    (lib.mkIf cfg.git.enable {
      programs.git = {
        enable = true;
        settings = import ./git/config.nix;
      };

      programs.delta = {
        enable = cfg.git.delta;
        enableGitIntegration = true;
      };

      home.file.".config/git/message".source = ./git/message;
    })

    (lib.mkIf (cfg.aerc && cfg.secrets) {
      programs.aerc = {
        enable = true;
        extraAccounts = builtins.readFile ./aerc/accounts.conf;
        extraConfig.general.unsafe-accounts-conf = true;
        extraConfig.filters = {
          "text/plain" = "colorize";
          "text/calendar" = "calendar";
          "message/delivery-status" = "colorize";
          "message/rfc822" = "colorize";
          "text/html" = "html | colorize";
          "image/*" = "catimg -w $(tput cols) -";
        };
      };
    })

    (lib.mkIf cfg.secrets {
      sops = {
        age.keyFile = "${config.home.homeDirectory}/.config/sops/age/keys.txt";
        defaultSopsFile = ../../secrets/home.yaml;
        secrets."email/mail@wantguns.dev/source".path =
          "%r/email/mail@wantguns.dev/source";
        secrets."email/mail@wantguns.dev/outgoing".path =
          "%r/email/mail@wantguns.dev/outgoing";
        secrets."email/void@wantguns.dev/source".path =
          "%r/email/void@wantguns.dev/source";
        secrets."email/void@wantguns.dev/outgoing".path =
          "%r/email/void@wantguns.dev/outgoing";
        secrets."miniflux/apitoken".path = "%r/miniflux/apitoken";
      };
    })

    (lib.mkIf cfg.alacritty {
      programs.alacritty.enable = true;
      home.file.".config/alacritty/alacritty.toml".source =
        ./alacritty/alacritty.toml;
    })


    (lib.mkIf cfg.ghostty {
      programs.ghostty = {
        enable = true;
        package = pkgs.ghostty-bin;
        settings = {
        font-family = "Iosevka Term SS15";
        font-size = 16;
        font-thicken = true;
        window-decoration = false;

        # disable ligatures
        font-feature = "-calt";

        theme =
          if cfg.theme == "gruvbox-light" then "Gruvbox Light"
          else if cfg.theme == "moonfly" then "Moonfly"
          else "moonfly";
        cursor-style = "block";
        };
      };
    })


    (lib.mkIf cfg.newsboat {
      programs.newsboat = {
        enable = true;
        extraConfig = builtins.readFile ./newsboat/config;
      };
    })
  ];
}
