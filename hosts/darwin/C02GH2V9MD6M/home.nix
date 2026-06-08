{ config, pkgs, ... }:
{
  features = {
    editors.nvim = {
      enable = true;
      ui = true;
      lsp = true;
      copilot = true;
      obsidian = true;
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
    alacritty = true;
    newsboat = true;

    dev = {
      go = true;
      python = true;
    };
  };

  home.file = {
    "dev/ola/.gitconfig".source = ./git/ola;
    "dev/ola/.gitmessage".source = ./git/olamessage;
  };
  programs.git.extraConfig.core.sshCommand = "ssh -i /Users/gunwant.jain1/.ssh/wantguns_gh";
  programs.git.includes = [
    {
      condition = "gitdir/i:~/dev/ola";
      path = "~/dev/ola/.gitconfig";
    }
  ];
}
