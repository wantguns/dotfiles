{ config, osConfig, lib, ... }:

let
  cfg = config.features.desktop;
  active = (osConfig.desktop.compositor or "none") != "none";
in

lib.mkIf (active && cfg.lock == "swaylock") {
  programs.swaylock = {
    enable = true;
    settings = {
      color = "1a1a1a";
      indicator-radius = 100;
      indicator-thickness = 7;
      ring-color = "3a3a3a";
      key-hl-color = "80a0ff";
      inside-color = "1a1a1a";
      text-color = "c6c6c6";
    };
  };
}
