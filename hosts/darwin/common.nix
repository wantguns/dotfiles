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

    NSGlobalDomain = {
      "com.apple.mouse.tapBehavior" = 1; # enable tap to click

      InitialKeyRepeat = 10;
      KeyRepeat = 1;
    };
  };
}
