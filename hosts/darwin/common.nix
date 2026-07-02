{ config, pkgs, ... }:
{
  system.stateVersion = 6;

  # in Determinate, we trust
  nix.enable = false;

  # set this to wantguns so that the system settings get applied 
  # when switching as wantguns
  system.primaryUser = "wantguns";

  system.defaults = {
    dock = {
      autohide = true;
      show-process-indicators = true;
      show-recents = false;
      static-only = true;
    };

    finder = {
      AppleShowAllExtensions = true;
      ShowPathbar = true;
      FXEnableExtensionChangeWarning = false;
    };

    trackpad = {
      Clicking = true;
      TrackpadRightClick = true;
    };

    NSGlobalDomain = {
      InitialKeyRepeat = 10;
      KeyRepeat = 1;
    };

    controlcenter = {
      BatteryShowPercentage = true;
      NowPlaying = true;
      Bluetooth = false;
      Sound = false;
      Display = false;
      FocusModes = false;
      AirDrop = false;
    };
    
    # remove widgets on desktop
    WindowManager.StandardHideWidgets = true;
  };
}
