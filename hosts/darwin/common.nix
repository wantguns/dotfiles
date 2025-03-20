{ config, pkgs, ... }: {
  system.stateVersion = 6;

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
      InitialKeyRepeat = 10;
      KeyRepeat = 1;
    };
  };
}

