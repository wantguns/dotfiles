{ config, pkgs, lib, ... }:

let cfg = config.features; in

lib.mkIf cfg.mpv {
  programs.mpv = {
    enable = true;
    scripts = with pkgs.mpvScripts; [
      twitch-chat
      sponsorblock-minimal
      quality-menu
    ];
  };
  programs.streamlink.enable = true;
}
