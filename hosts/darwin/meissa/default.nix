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
    itsycal
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
      yq
      mosh
      shadowsocks-rust

      gnumake
      go
      python312
      python312Packages.pyyaml
      pipx
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
