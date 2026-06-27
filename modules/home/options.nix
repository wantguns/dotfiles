{ lib, ... }:

with lib;

{
  options.features = {
    theme = lib.mkOption {
      type = lib.types.enum [
        "moonfly"
        "gruvbox-light"
      ];
      default = "moonfly";
      description = "Selected terminal theme";
    };
    editors = {
      nvim = {
        enable = mkEnableOption "neovim editor";
        ui = mkEnableOption "add ui elements";
        lsp = mkEnableOption "neovim LSP and treesitter support";
        copilot = mkEnableOption "enable copilot";
        obsidian = mkEnableOption "enable obsidian";
      };

      emacs = {
        enable = mkEnableOption "emacs editor";
      };
    };

    ai = {
      opencode = mkEnableOption "enable opencode";
      pi = mkEnableOption "enable pi-coding-agent";
    };

    shell = {
      zsh = {
        enable = mkEnableOption "zsh shell";
        powerlevel10k = mkEnableOption "powerlevel10k theme";
      };
    };

    tmux = mkEnableOption "tmux terminal multiplexer";
    fzf = mkEnableOption "fzf fuzzy finder";

    dev = {
      go = mkEnableOption "go development environment";
      rust = mkEnableOption "rust development environment";
      python = mkEnableOption "python development environment";
      terraform = mkEnableOption "enable terraform environment";
      nodejs = mkEnableOption "enable javascript/typescript environment";
      lua = mkEnableOption "enable lua environment";
      zig = mkEnableOption "enable zig environment";
    };

    git = {
      enable = mkEnableOption "git";
      delta = mkEnableOption "git-delta";
    };

    aerc = mkEnableOption "aerc email client";
    alacritty = mkEnableOption "alacritty terminal";
    ghostty = mkEnableOption "ghostty terminal";
    kubernetes = mkEnableOption "kubernetes tooling";
    newsboat = mkEnableOption "newsboat rss reader";
    mpv = mkEnableOption "mpv and streamlink";
    firefox = mkEnableOption "firefox";
  };
}
