{ config, pkgs, ... }:
{
  features = {
    editors.nvim = {
      enable = true;
      ui = true;
      lsp = false;
      copilot = true;
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
    aerc = false;
    alacritty = false;
    newsboat = false;

    dev = {
      go = false;
      python = false;
    };
  };
}
