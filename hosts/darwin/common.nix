{ config, pkgs, ... }: {
  system.stateVersion = 6;

  system.primaryUser = "root";

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

