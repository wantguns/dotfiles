{ config, osConfig, lib, ... }:

let
  cfg = config.features.desktop;
  font = "Iosevka Term SS15";
  active = (osConfig.desktop.compositor or "none") != "none";
in

lib.mkIf (active && cfg.menubar == "waybar") {
  programs.waybar = {
    enable = true;
    systemd.enable = true;
    settings.mainBar = {
      layer = "top";
      position = "top";
      height = 28;
      spacing = 8;
      modules-left = [ "niri/workspaces" ];
      modules-center = [ "clock" ];
      modules-right = [ "tray" "network" "bluetooth" "wireplumber" ];

      "niri/workspaces" = { };

      clock = {
        format = "{:%a %d %b  %H:%M}";
        tooltip-format = "<tt>{calendar}</tt>";
      };

      network = {
        format-wifi = "wifi {signalStrength}%";
        format-ethernet = "eth";
        format-disconnected = "net off";
        tooltip-format = "{ifname}: {ipaddr}";
        on-click = "nm-connection-editor";
      };

      bluetooth = {
        format = "bt {status}";
        format-connected = "bt {num_connections}";
        on-click = "blueman-manager";
      };

      wireplumber = {
        format = "vol {volume}%";
        format-muted = "vol mute";
        on-click = "wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle";
        on-scroll-up = "wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+";
        on-scroll-down = "wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-";
      };

      tray = { spacing = 8; };
    };
    style = ''
      * {
        font-family: "${font}", monospace;
        font-size: 13px;
        min-height: 0;
      }
      window#waybar {
        background: #1a1a1a;
        color: #c6c6c6;
      }
      #workspaces button {
        padding: 0 8px;
        color: #808080;
        background: transparent;
      }
      #workspaces button.active {
        color: #1a1a1a;
        background: #80a0ff;
      }
      #clock,
      #network,
      #bluetooth,
      #wireplumber,
      #tray {
        padding: 0 10px;
      }
    '';
  };
}
