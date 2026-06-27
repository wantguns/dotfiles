{ config, osConfig, lib, ... }:
lib.mkIf ((osConfig.desktop.compositor or "none") == "niri") {
  xdg.configFile."niri/config.kdl".source = ./config.kdl;
}
