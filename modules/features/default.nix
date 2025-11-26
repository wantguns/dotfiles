{ lib, ... }:

with lib;

{
  options.features = {
    editors = {
      nvim = {
        enable = mkEnableOption "neovim editor";
        ui = mkEnableOption "add ui elements";
        lsp = mkEnableOption "neovim LSP and treesitter support";
        copilot = mkEnableOption "enable copilot";
        obsidian = mkEnableOption "enable obsidian";
      };
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
      enable = mkEnableOption "git with delta";
      delta = mkEnableOption "git-delta";
    };

    aerc = mkEnableOption "aerc email client";
    alacritty = mkEnableOption "alacritty terminal";
    newsboat = mkEnableOption "newsboat RSS reader";
    secrets = mkEnableOption "mount secrets";
  };
}
