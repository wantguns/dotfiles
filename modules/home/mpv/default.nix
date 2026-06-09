{
  config,
  pkgs,
  lib,
  ...
}:

let
  cfg = config.features;
in

lib.mkIf cfg.mpv {
  programs.mpv = {
    enable = true;
    extraMakeWrapperArgs = lib.optionals pkgs.stdenv.hostPlatform.isDarwin [
      "--add-flags"
      "--osd-font-provider=fontconfig"
    ];
    scripts = [
      pkgs.mpvScripts.uosc
      pkgs.mpvScripts.twitch-chat
      pkgs.mpvScripts.sponsorblock-minimal
      pkgs.mpvScripts.quality-menu
    ];
    config = {
      sub-font = "Noto Sans Bold";
      sub-font-size = 30;
      sub-color = "0.89/0.69/0.02/0.9";
      sub-back-color = "0.0/0.0/0.0/0.20";
      sub-border-size = 0;
      sub-border-style = "background-box";
      sub-shadow-offset = 5;
      sub-blur = 0.01;
    };
  };
  home.packages = [ pkgs.noto-fonts ];
  programs.streamlink.enable = true;
}
