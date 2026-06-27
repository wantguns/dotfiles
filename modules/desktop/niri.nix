{ config, pkgs, ... }:
{
  programs.niri.enable = true;

  security.rtkit.enable = true;

  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
  };
  services.blueman.enable = true;

  environment.sessionVariables = {
    NIXOS_OZONE_WL = "1";
    LIBVA_DRIVER_NAME = "radeonsi";
  };

  environment.systemPackages = with pkgs; [
    xwayland-satellite
  ];

  services.greetd = {
    enable = true;
    settings.default_session = {
      command = "${config.services.greetd.package}/bin/agreety --cmd niri-session";
      user = "greeter";
    };
  };

  systemd.user.services.niri.enableDefaultPath = false;
}
