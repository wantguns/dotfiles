{ config, osConfig, lib, pkgs, ... }:

let
  cfg = config.features.desktop;
  active = (osConfig.desktop.compositor or "none") != "none";
  hasLock = cfg.lock == "swaylock";
  lockCmd = "${pkgs.swaylock}/bin/swaylock -f";
in

lib.mkIf (active && cfg.idle == "swayidle") {
  services.swayidle = {
    enable = true;
    timeouts =
      (lib.optionals hasLock [ { timeout = 300; command = lockCmd; } ])
      ++ [
        {
          timeout = 330;
          command = "/run/current-system/sw/bin/niri msg action power-off-monitors";
        }
      ];
    events = lib.optionalAttrs hasLock {
      before-sleep = lockCmd;
    };
  };
}
