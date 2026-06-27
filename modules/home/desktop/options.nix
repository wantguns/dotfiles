{ lib, ... }:
with lib;
{
  options.features.desktop = {
    menubar = mkOption {
      type = types.enum [ "none" "waybar" ];
      default = "waybar";
      description = "status bar implementation";
    };
    launcher = mkOption {
      type = types.enum [ "none" "fuzzel" ];
      default = "fuzzel";
      description = "application launcher";
    };
    notification = mkOption {
      type = types.enum [ "none" "mako" ];
      default = "mako";
      description = "notification daemon";
    };
    lock = mkOption {
      type = types.enum [ "none" "swaylock" ];
      default = "swaylock";
      description = "screen locker";
    };
    idle = mkOption {
      type = types.enum [ "none" "swayidle" ];
      default = "swayidle";
      description = "idle manager";
    };
    background = mkOption {
      type = types.enum [ "none" "swaybg" ];
      default = "swaybg";
      description = "wallpaper daemon";
    };
    clipboard = mkOption {
      type = types.enum [ "none" "cliphist" ];
      default = "cliphist";
      description = "clipboard history manager";
    };
  };
}
