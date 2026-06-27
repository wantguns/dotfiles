{ config, osConfig, lib, pkgs, ... }:

let
  cfg = config.features.desktop;
  active = (osConfig.desktop.compositor or "none") != "none";
in

lib.mkIf (active && cfg.background == "swaybg") {
  systemd.user.services.swaybg = {
    Unit = {
      Description = "swaybg wallpaper";
      PartOf = [ "graphical-session.target" ];
      After = [ "graphical-session.target" ];
    };
    Service = {
      ExecStart = "${pkgs.swaybg}/bin/swaybg -c 1a1a1a";
      Restart = "on-failure";
    };
    Install.WantedBy = [ "graphical-session.target" ];
  };
}
