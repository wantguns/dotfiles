{ config, lib, ... }:

let cfg = config.features; in

lib.mkIf cfg.fzf {
  programs.fzf.enable = true;
}
