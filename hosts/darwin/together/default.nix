{ config, pkgs, ... }:
{
  networking.hostName = "together";

  environment.systemPackages = with pkgs; [
    raycast
    rectangle
  ];

  homebrew = {
    enable = true;
    user = "wantguns";

    casks = [
      "slack"
      "discord"
      "spotify"
      "signal"
      "zoom"
      "jellyfin-media-player"
    ];
  };

  users.users."wantguns" = {
    shell = pkgs.zsh;
    home = "/Users/wantguns";
    packages = with pkgs; [
      bat
      curl
      fd
      gnumake
      htop
      jq
      yq-go
      ncdu
      tree
      wget
      zola
      chatterino2
      wireguard-tools
    ];
  };

  system.defaults.CustomUserPreferences = {
    "com.apple.symbolichotkeys" = {
      AppleSymbolicHotKeys = {
        "64".enabled = false; # Disable 'Cmd + Space' for Spotlight Search
      };
    };
  };

  security.pam.services.sudo_local.touchIdAuth = true;
}
