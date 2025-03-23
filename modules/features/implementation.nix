{ config, pkgs, lib, ... }:

let
  cfg = config.features;

  toLua = str: "\nlua << EOF\n${str}\nEOF";
  toLuaFile = file: "\nlua << EOF\n${builtins.readFile file}\nEOF";

  fromGitHub = { ref, repo, sha256 ? lib.fakeSha256 }:
    pkgs.vimUtils.buildVimPlugin {
      pname = "${lib.strings.sanitizeDerivationName repo}";
      version = ref;
      src = pkgs.fetchFromGitHub {
        owner = lib.strings.elemAt (lib.strings.splitString "/" repo) 0;
        repo = lib.strings.elemAt (lib.strings.splitString "/" repo) 1;
        rev = ref;
        sha256 = sha256;
      };
    };

  fakeVimPlugin = pkgs.runCommand "fakeVimPlugin" { } "mkdir $out";
in
{
  config = lib.mkMerge [
    {
      home = {
        stateVersion = "24.11";
        packages = with pkgs; [
          (lib.mkIf cfg.alacritty nerd-fonts.iosevka-term)
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

        plugins = with pkgs.vimPlugins; [
          {
            plugin = fakeVimPlugin;
            config = toLuaFile ./nvim/base.lua;
          }
          plenary-nvim
        ]
        ++ lib.optional cfg.editors.nvim.copilot copilot-vim

        ++ lib.optionals cfg.editors.nvim.ui [
          which-key-nvim
          {
            plugin = gitlinker-nvim;
            config = toLua ''require('gitlinker').setup()'';
          }
          {
            plugin = gitsigns-nvim;
            config = toLua ''require('gitsigns').setup()'';
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
            plugin = fromGitHub {
              ref = "HEAD";
              repo = "bluz71/vim-moonfly-colors";
              sha256 = "3nEbXoy0dJks7yKgkk23DvqeWMtZF2V/tKb+1gv3cSs=";
            };
            config = "colorscheme moonfly";
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

        # Obsidian
        ++ lib.optional cfg.editors.nvim.obsidian {
          plugin = obsidian-nvim;
          config = toLuaFile ./nvim/obsidian.lua;
        };

        extraPackages = with pkgs; [
          (lib.mkIf cfg.dev.go gopls)
          (lib.mkIf cfg.dev.python pyright)
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

        completionInit = ''autoload -U compinit && compinit -u'';

        history = {
          append = true;
          extended = true;
          size = 10000;
          save = 1000000;
        };

        initExtraFirst = builtins.readFile ./zsh/zshrc;

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

    (lib.mkIf cfg.fzf {
      programs.fzf.enable = true;
    })

    (lib.mkIf cfg.tmux {
      programs.tmux = {
        enable = true;
        extraConfig = builtins.readFile ./tmux/tmux.conf;
      };
    })

    (lib.mkIf cfg.git.enable {
      programs.git = {
        enable = true;
        extraConfig = import ./git/config.nix;
        delta.enable = cfg.git.delta;
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
        secrets."email/mail@wantguns.dev/source".path = "%r/email/mail@wantguns.dev/source";
        secrets."email/mail@wantguns.dev/outgoing".path = "%r/email/mail@wantguns.dev/outgoing";
        secrets."email/void@wantguns.dev/source".path = "%r/email/void@wantguns.dev/source";
        secrets."email/void@wantguns.dev/outgoing".path = "%r/email/void@wantguns.dev/outgoing";
        secrets."miniflux/apitoken".path = "%r/miniflux/apitoken";
      };
    })

    (lib.mkIf cfg.alacritty {
      programs.alacritty.enable = true;
      home.file.".config/alacritty/alacritty.toml".source = ./alacritty/alacritty.toml;
    })

    (lib.mkIf cfg.newsboat {
      programs.newsboat = {
        enable = true;
        extraConfig = builtins.readFile ./newsboat/config;
      };
    })
  ];
}
