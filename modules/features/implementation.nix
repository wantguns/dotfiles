{ config, pkgs, lib, ... }:

let
  cfg = config.features;

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

in {
  config = lib.mkMerge [
    {
      home = {
        stateVersion = "26.05";
        packages = with pkgs; [
          (lib.mkIf cfg.alacritty nerd-fonts.iosevka-term)
          (iosevka-bin.override { variant = "SS15"; })
          ripgrep
          (lib.mkIf cfg.kubernetes kubectl)
          (lib.mkIf cfg.kubernetes kubernetes-helm)

          (lib.mkIf cfg.dev.lua lua-language-server)
          (lib.mkIf cfg.dev.go gopls)
          (lib.mkIf cfg.dev.go golangci-lint-langserver)
          (lib.mkIf cfg.dev.python ty)
          (lib.mkIf cfg.dev.terraform terraform-ls)
          (lib.mkIf cfg.dev.nodejs typescript-language-server)
          (lib.mkIf cfg.dev.nodejs typescript)
          (lib.mkIf cfg.dev.zig zls)
        ];
      };

      fonts.fontconfig.enable = true;
      programs.home-manager.enable = true;
    }

    (lib.mkIf cfg.editors.emacs.enable {
      programs.emacs = {
        enable = true;

        extraPackages = (epkgs: [ epkgs.vterm epkgs.treesit-grammars.with-all-grammars ]);
      };

      services.emacs.enable = true;
    })

    (lib.mkIf cfg.editors.nvim.enable {
      programs.neovim = {
        enable = true;
        defaultEditor = true;
        viAlias = true;
        vimAlias = true;
        vimdiffAlias = true;
        initLua = lib.mkBefore (builtins.readFile ./nvim/base.lua);

        extraPackages = with pkgs; [
          (lib.mkIf cfg.editors.nvim.lsp tree-sitter)
        ];

        plugins = with pkgs.vimPlugins;
          [
            plenary-nvim
          ] 
          ++ lib.optional (cfg.theme == "gruvbox-light") {
              plugin = gruvbox;
              config = "vim.cmd(\"set background=light | set termguicolors | colorscheme gruvbox\")";
            }
          ++ lib.optional (cfg.theme == "moonfly")
            { 
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
              config = builtins.readFile ./nvim/opencode.lua;
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
              config = builtins.readFile ./nvim/gitlink.lua;
            }
            {
              plugin = gitsigns-nvim;
              config = "require('gitsigns').setup()";
            }
            {
              plugin = lualine-nvim;
              config = builtins.readFile ./nvim/lualine.lua;
            }
            {
              plugin = oil-nvim;
              config = builtins.readFile ./nvim/oil.lua;
            }
            {
              plugin = telescope-nvim;
              config = builtins.readFile ./nvim/telescope.lua;
            }
            {
              plugin = telescope-nvim;
              config = builtins.readFile ./nvim/telescope.lua;
            }
          ]

          ++ lib.optionals cfg.editors.nvim.lsp [
            {
              plugin = nvim-treesitter.withAllGrammars;
              config = builtins.readFile ./nvim/treesitter.lua;
            }
            {
              plugin = nvim-lspconfig;
              config = builtins.readFile ./nvim/lsp.lua;
            }
            {
              plugin = nvim-cmp;
              config = builtins.readFile ./nvim/cmp.lua;
            }
            cmp-nvim-lsp
          ]

          ++ lib.optionals cfg.dev.terraform [
            nvim-treesitter-parsers.terraform
          ]

          # Obsidian
          ++ lib.optional cfg.editors.nvim.obsidian {
            plugin = obsidian-nvim;
            config = builtins.readFile ./nvim/obsidian.lua;
          };
      };
    })

    (lib.mkIf cfg.shell.zsh.enable {
      programs.zsh = {
        enable = true;
        syntaxHighlighting.enable = true;
        autosuggestion.enable = true;
        enableCompletion = true;
        
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

    (lib.mkIf cfg.ai (let
      opencode-src = pkgs.fetchFromGitHub {
        owner = "anomalyco";
        repo = "opencode";
        tag = "v1.2.20";
        hash = "sha256-FBmF7/uwZYY/qY1252Hz+XhXdE+Qp5axySAy5Jw7XUQ=";
      };
    in {
      home.packages = [
        (pkgs.opencode.overrideAttrs (old: {
          version = "1.2.20-add-dir";
          src = opencode-src;
          patches = (old.patches or []) ++ [
            (pkgs.fetchpatch {
              url = "https://github.com/anomalyco/opencode/pull/8943.diff";
              hash = "sha256-YQio9KtusTn0lozSxgPXY++w7njKQzRx0F0RBnZ8tzU=";
            })
          ];
          node_modules = old.node_modules.overrideAttrs {
            src = opencode-src;
            outputHash = "sha256-OwlJRAeKnX5YMwQgaV4op40rjt5kxsP4WrOzpp9t90w=";
          };
        }))
      ];
    }))

    (lib.mkIf cfg.kubernetes {
      programs.k9s = {
        enable = true;
        settings = {
          k9s = {
            ui = {
              headless = true;
              logoless = true;
            };
            skin = "transparent";
          };
        };
        skins = {
          transparent = ./k9s/transparent-skin.yaml;
        };
      };
    })
  ];
}
