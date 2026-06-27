{
  config,
  pkgs,
  lib,
  ...
}:

let
  cfg = config.features;
  font = "Iosevka Term";
in

lib.mkIf cfg.niri {
  home.packages = with pkgs; [
    wl-clipboard
    cliphist
    nerd-fonts.iosevka-term
  ];

  xdg.configFile."niri/config.kdl".source = ./config.kdl;

  programs.fuzzel = {
    enable = true;
    settings = {
      main = {
        font = "${font}:size=12";
        terminal = "ghostty";
        layer = "overlay";
      };
      colors = {
        background = "1a1a1aff";
        text = "c6c6c6ff";
        selection = "80a0ffff";
        selection-text = "1a1a1aff";
        border = "80a0ffff";
      };
    };
  };

  programs.waybar = {
    enable = true;
    settings.mainBar = {
      layer = "top";
      position = "top";
      height = 28;
      spacing = 8;
      modules-left = [ "niri/workspaces" ];
      modules-center = [ "clock" ];
      modules-right = [
        "tray"
        "network"
        "bluetooth"
        "wireplumber"
      ];

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

      tray = {
        spacing = 8;
      };
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

  services.mako = {
    enable = true;
    settings = {
      background-color = "#1a1a1a";
      text-color = "#c6c6c6";
      border-color = "#80a0ff";
      border-radius = 6;
      default-timeout = 5000;
      font = "${font} 11";
    };
  };

  programs.swaylock = {
    enable = true;
    settings = {
      color = "1a1a1a";
      indicator-radius = 100;
      indicator-thickness = 7;
      ring-color = "3a3a3a";
      key-hl-color = "80a0ff";
      inside-color = "1a1a1a";
      text-color = "c6c6c6";
    };
  };

  services.swayidle = {
    enable = true;
    timeouts = [
      {
        timeout = 300;
        command = "${pkgs.swaylock}/bin/swaylock -f";
      }
      {
        timeout = 330;
        command = "/run/current-system/sw/bin/niri msg action power-off-monitors";
      }
    ];
    events = [
      {
        event = "before-sleep";
        command = "${pkgs.swaylock}/bin/swaylock -f";
      }
    ];
  };

  services.network-manager-applet.enable = true;
  services.blueman-applet.enable = true;

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
