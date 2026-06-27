{ config, osConfig, lib, ... }:

let
  cfg = config.features.desktop;
  font = "Iosevka Term SS15";
  active = (osConfig.desktop.compositor or "none") != "none";
in

lib.mkIf (active && cfg.notification == "mako") {
  services.mako = {
    enable = true;
    settings = {
      background-color = "#1a1a1a";
      text-color = "#c6c6c6";
      border-color = "#80a0ff";
      border-radius = 6;
      default-timeout = 5000;
      font = "${font} 11";
    };
  };
}
