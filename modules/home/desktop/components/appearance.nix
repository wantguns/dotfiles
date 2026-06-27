{ config, osConfig, lib, pkgs, ... }:

let
  active = (osConfig.desktop.compositor or "none") != "none";

  bg = "#1a1a1a";
  bgAlt = "#232323";
  sidebar = "#161616";
  fg = "#c6c6c6";
  accent = "#80a0ff";
  border = "#3a3a3a";

  gtk3Css = ''
    @define-color theme_bg_color ${bg};
    @define-color theme_base_color ${bg};
    @define-color theme_fg_color ${fg};
    @define-color theme_text_color ${fg};
    @define-color theme_selected_bg_color ${accent};
    @define-color theme_selected_fg_color ${bg};
    @define-color insensitive_bg_color ${bg};
    @define-color borders ${border};
  '';

  gtk4Css = ''
    @define-color window_bg_color ${bg};
    @define-color window_fg_color ${fg};
    @define-color view_bg_color ${bg};
    @define-color view_fg_color ${fg};
    @define-color headerbar_bg_color ${bg};
    @define-color headerbar_fg_color ${fg};
    @define-color sidebar_bg_color ${sidebar};
    @define-color sidebar_fg_color ${fg};
    @define-color card_bg_color ${bgAlt};
    @define-color popover_bg_color ${bgAlt};
    @define-color dialog_bg_color ${bg};
    @define-color accent_bg_color ${accent};
    @define-color accent_fg_color ${bg};
    @define-color accent_color ${accent};
  '';
in

lib.mkIf active {
  # universal dark signal: GTK, libadwaita, electron (via portal)
  dconf.settings."org/gnome/desktop/interface" = {
    color-scheme = "prefer-dark";
    gtk-theme = "Adwaita-dark";
  };

  gtk = {
    enable = true;
    theme = {
      name = "Adwaita-dark";
      package = pkgs.gnome-themes-extra;
    };
    iconTheme = {
      name = "Adwaita";
      package = pkgs.adwaita-icon-theme;
    };
    gtk3.extraConfig.gtk-application-prefer-dark-theme = 1;
    gtk4.extraConfig.gtk-application-prefer-dark-theme = 1;
  };

  # moonfly palette overrides on top of the dark base
  xdg.configFile."gtk-3.0/gtk.css".text = gtk3Css;
  xdg.configFile."gtk-4.0/gtk.css".text = gtk4Css;
}
