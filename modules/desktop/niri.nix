{ config, pkgs, lib, ... }:
lib.mkIf (config.desktop.compositor == "niri") {
  programs.niri.enable = true;

  environment.systemPackages = with pkgs; [ xwayland-satellite ];

  services.greetd = {
    enable = true;
    settings.default_session = {
      command = "${config.services.greetd.package}/bin/agreety --cmd niri-session";
      user = "wantguns";
    };
  };

  systemd.user.services.niri.enableDefaultPath = false;
}
