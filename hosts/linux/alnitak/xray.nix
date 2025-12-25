{ config, pkgs, lib, inputs, ... }:
{
  networking.firewall = {
    allowedTCPPorts = [
      7890
      7891
    ];
    allowedUDPPorts = [
      7890
      7891
    ];
  };

  sops.secrets = {
    "xray/alnitak" = {};
  };

  services.xray = {
    enable = true;
    settingsFile = "/run/secrets/xray/alnitak";
  };
}
