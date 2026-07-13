{
  config,
  pkgs,
  lib,
  ...
}:

let
  cfg = config.features;
in

lib.mkIf cfg.firefox {
  programs.firefox = {
    enable = true;

    languagePacks = [ "en-US" ];

    policies = {
      # Updates & Background Services
      AppAutoUpdate = false;
      BackgroundAppUpdate = false;

      # Feature Disabling
      DisableFirefoxStudies = true;
      DisableFirefoxAccounts = true;
      DisableFirefoxScreenshots = true;
      DisableForgetButton = true;
      DisableMasterPasswordCreation = true;
      DisableProfileImport = true;
      DisableProfileRefresh = true;
      DisableSetDesktopBackground = true;
      DisablePocket = true;
      DisableTelemetry = true;
      DisableFormHistory = true;
      EnableTrackingProtection.Value = true;
      ExtensionUpdate = false;
      NetworkPrediction = false;
      NoDefaultBookmarks = true;
      PasswordManagerEnabled = false;
      GenerativeAI.Enabled = false;

      # Access Restrictions
      BlockAboutConfig = false;
      BlockAboutProfiles = true;
      BlockAboutSupport = true;

      # UI and Behavior
      DisplayMenuBar = "never";
      DontCheckDefaultBrowser = true;
      OfferToSaveLogins = false;
      DefaultDownloadDirectory = "${config.home.homeDirectory}/Downloads";
      ShowHomeButton = false;
      FirefoxHome = {
        Search = true;
        TopSites = true;
        SponsoredTopSites = false;
        Highlights = false;
        Pocket = false;
        SponsoredPocket = false;
        Snippets = false;
      };

      # Extensions
      ExtensionSettings =
        let
          moz = short: "https://addons.mozilla.org/firefox/downloads/latest/${short}/latest.xpi";
        in
        {
          "*".installation_mode = "blocked";

          "uBlock0@raymondhill.net" = {
            install_url = moz "ublock-origin";
            installation_mode = "normal_installed";
            updates_disabled = true;
            private_browsing = true;
            default_area = "navbar";
          };

          "{446900e4-71c2-419f-a6a7-df9c091e268b}" = {
            install_url = moz "bitwarden-password-manager";
            installation_mode = "normal_installed";
            updates_disabled = true;
            private_browsing = true;
            default_area = "navbar";
          };

          "addon@darkreader.org" = {
            install_url = moz "darkreader";
            installation_mode = "normal_installed";
            updates_disabled = true;
            private_browsing = true;
            default_area = "navbar";
          };

          "jid1-xUfzOsOFlzSOXg@jetpack" = {
            install_url = moz "reddit-enhancement-suite";
            installation_mode = "normal_installed";
            updates_disabled = true;
            private_browsing = true;
          };

          "{9063c2e9-e07c-4c2c-9646-cfe7ca8d0498}" = {
            install_url = moz "old-reddit-redirect";
            name = "old-reddit-redirect";
            installation_mode = "normal_installed";
            updates_disabled = true;
            private_browsing = true;
          };

          "switchyomega@feliscatus.addons.mozilla.org" = {
            install_url = moz "switchyomega";
            name = "switchyomega";
            installation_mode = "normal_installed";
            updates_disabled = true;
            private_browsing = true;
          };
        };

      # Extension configuration
      "3rdparty".Extensions = {
        "uBlock0@raymondhill.net".adminSettings = {
          userSettings = rec {
            uiTheme = "dark";
            uiAccentCustom = true;
            uiAccentCustom0 = "#8300ff";
            cloudStorageEnabled = lib.mkForce false;

            importedLists = [
              "https:#filters.adtidy.org/extension/ublock/filters/3.txt"
              "https:#github.com/DandelionSprout/adfilt/raw/master/LegitimateURLShortener.txt"
            ];

            externalLists = lib.concatStringsSep "\n" importedLists;
          };

          selectedFilterLists = [
            "CZE-0"
            "adguard-generic"
            "adguard-annoyance"
            "adguard-social"
            "adguard-spyware-url"
            "easylist"
            "easyprivacy"
            "https:#github.com/DandelionSprout/adfilt/raw/master/LegitimateURLShortener.txt"
            "plowe-0"
            "ublock-abuse"
            "ublock-badware"
            "ublock-filters"
            "ublock-privacy"
            "ublock-quick-fixes"
            "ublock-unbreak"
            "urlhaus-1"
          ];
        };
      };
    };

    profiles.default = {
      search = {
        force = true;
        default = "ddg";
        privateDefault = "ddg";
      };
      settings = {
        "sidebar.revamp" = true;
        "sidebar.visibility" = "expand-on-hover";
        "sidebar.verticalTabs" = true;
        "sidebar.animation.expand-on-hover.duration-ms" = 150;
        "browser.toolbars.bookmarks.visibility" = "never";

        "browser.uiCustomization.state" = builtins.toJSON {
          placements = {
            nav-bar = [
              "alltabs-button"
              "back-button"
              "forward-button"
              "urlbar-container"
              "ublock0_raymondhill_net-browser-action"
              "addon_darkreader_org-browser-action"
              "_446900e4-71c2-419f-a6a7-df9c091e268b_-browser-action"
              "unified-extensions-button"
            ];
          };
          seen = [
            "addon_darkreader_org-browser-action"
            "ublock0_raymondhill_net-browser-action"
            "_446900e4-71c2-419f-a6a7-df9c091e268b_-browser-action"
          ];
        };
      };
    };
  };
}
