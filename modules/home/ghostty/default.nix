{ config, pkgs, lib, ... }:

let cfg = config.features; in

lib.mkIf cfg.ghostty {
  programs.ghostty = {
    enable = true;
    package = pkgs.ghostty-bin;
    settings = {
      font-family = "Iosevka Term SS15";
      font-size = 16;
      font-thicken = true;
      window-decoration = false;

      # disable ligatures
      font-feature = "-calt";

      theme =
        if cfg.theme == "gruvbox-light" then "Gruvbox Light"
        else if cfg.theme == "moonfly" then "Moonfly"
        else "moonfly";
      cursor-style = "block";
    };
  };
}
