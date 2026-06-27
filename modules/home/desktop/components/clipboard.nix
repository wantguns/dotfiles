{ config, osConfig, lib, pkgs, ... }:

let
  cfg = config.features.desktop;
  active = (osConfig.desktop.compositor or "none") != "none";
in

lib.mkIf (active && cfg.clipboard == "cliphist") {
  home.packages = with pkgs; [ wl-clipboard cliphist ];

  systemd.user.services.cliphist = {
    Unit = {
      Description = "clipboard history (cliphist)";
      PartOf = [ "graphical-session.target" ];
      After = [ "graphical-session.target" ];
    };
    Service = {
      ExecStart = "${pkgs.wl-clipboard}/bin/wl-paste --type text --watch ${pkgs.cliphist}/bin/cliphist store";
      Restart = "on-failure";
    };
    Install.WantedBy = [ "graphical-session.target" ];
  };
}
