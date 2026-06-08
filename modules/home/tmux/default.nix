{ config, pkgs, lib, ... }:

let cfg = config.features; in

lib.mkIf cfg.tmux {
  programs.tmux = {
    enable = true;
    extraConfig = builtins.readFile ./tmux.conf;
  };
}
