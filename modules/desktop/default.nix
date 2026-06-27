{ lib, ... }:
{
  imports = [
    ./base.nix
    ./niri.nix
  ];

  options.desktop.compositor = lib.mkOption {
    type = lib.types.enum [ "none" "niri" ];
    default = "none";
    description = "system wayland compositor session (single choice)";
  };
}
