{ config, pkgs, ... }: {
  networking.hostName = "meissa";
  environment.systemPackages = with pkgs; [
    raycast
    firefox
    slack
    obsidian
    spotify
    feishin
    rectangle
    signal-desktop-bin
  ];

  users.users."wantguns" = {
    shell = pkgs.zsh;
    home = "/Users/wantguns";
    packages = with pkgs; [
      k9s
      kubectl
      kubernetes-helm
      xh
      jq
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
