{
  config,
  pkgs,
  lib,
  ...
}:

let
  cfg = config.features;
in

lib.mkIf cfg.ghostty {
  programs.ghostty = {
    enable = true;
    package = if pkgs.stdenv.hostPlatform.isDarwin then pkgs.ghostty-bin else pkgs.ghostty;
    settings = {
      font-family = "Iosevka Term SS15";
      font-size = 14;
      font-thicken = true;
      window-decoration = false;

      # disable ligatures
      font-feature = "-calt";
      shell-integration-features = "ssh-env,ssh-terminfo,sudo";

      # prevent option key to generate special characters, and be used as M-
      macos-option-as-alt = true;

      theme =
        if cfg.theme == "gruvbox-light" then
          "Gruvbox Light"
        else if cfg.theme == "moonfly" then
          "Moonfly"
        else
          "moonfly";
      cursor-style = "block";
    };
  };
}
