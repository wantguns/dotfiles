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
    secrets = true;
    alacritty = true;
    newsboat = false;

    dev = {
      go = false;
      python = false;
    };
  };

  home.file = {
    "dev/aion/.gitconfig".source = ./git/aion;
    "dev/aion/.gitmessage".source = ./git/aionmessage;
  };
  programs.git.includes = [{
    condition = "gitdir:~/dev/aion/";
    path = "~/dev/aion/.gitconfig";
  }];
}
