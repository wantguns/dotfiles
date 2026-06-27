{ config, osConfig, lib, ... }:

let
  cfg = config.features.desktop;
  font = "Iosevka Term SS15";
  active = (osConfig.desktop.compositor or "none") != "none";
in

lib.mkIf (active && cfg.launcher == "fuzzel") {
  programs.fuzzel = {
    enable = true;
    settings = {
      main = {
        font = "${font}:size=12";
        terminal = "ghostty";
        layer = "overlay";
      };
      colors = {
        background = "1a1a1aff";
        text = "c6c6c6ff";
        selection = "80a0ffff";
        selection-text = "1a1a1aff";
        border = "80a0ffff";
      };
    };
  };
}
