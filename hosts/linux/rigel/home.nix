{ config, pkgs, ... }:
{
  features = {
    theme = "moonfly";

    editors = {
      nvim = {
        enable = true;
        ui = true;
        lsp = true;
        copilot = false;
        obsidian = false;
      };
      emacs.enable = true;
    };

    ai = {
      opencode = false;
      pi = false;
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
    ghostty = true;
    newsboat = true;
    kubernetes = true;
    mpv = true;
    firefox = true;

    dev = {
      go = true;
      python = true;
      terraform = true;
      nodejs = true;
      lua = true;
      zig = true;
    };
  };
}
