{ config, pkgs, ... }: {
  features = {
    editors.nvim = {
      enable = true;
      ui = true;
      lsp = true;
      copilot = false;
      obsidian = false;
    };

    shell.zsh = {
      enable = true;
      powerlevel10k = true;
    };

    git = {
      enable = true;
      delta = true;
    };

    tmux = true;
    fzf = true;
    aerc = true;
    secrets = false;
    alacritty = true;
    newsboat = false;

    dev = {
      go = true;
      python = true;
      terraform = true;
      nodejs = true;
      lua = true;
      zig = true;
    };
  };

  home.file = {
    "dev/aion/.gitconfig".source = ./git/aion;
    "dev/aion/.gitmessage".source = ./git/aionmessage;
  };
  programs.git = {
      settings = {
        url."git@github-aion:aion-intelligence".insteadOf = "https://github.com/aion-intelligence";
      };
      includes = [{
        condition = "gitdir:~/dev/aion/";
        path = "~/dev/aion/.gitconfig";
      }];
  };
}
