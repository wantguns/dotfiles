{ config, pkgs, lib, ... }:

let cfg = config.features; in

lib.mkIf cfg.alacritty {
  home.packages = [ pkgs.nerd-fonts.iosevka-term ];
  programs.alacritty.enable = true;
  home.file.".config/alacritty/alacritty.toml".source = ./alacritty.toml;
}
