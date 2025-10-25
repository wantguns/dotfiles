{ config, pkgs, ... }: {
  networking.hostName = "meissa";
  environment.systemPackages = with pkgs; [
    # (libcanberra.override { gtkSupport = "gtk2"; })
    raycast
    (firefox.overrideAttrs (_: {
      gtk_modules = [ ];
    }))
    # firefox
    slack
    obsidian
    spotify
    feishin
    rectangle
    notion-app
    localsend
    discord
    iina
    # fx-cast-bridge
    google-chrome
    halloy
    yaak

    # block of shame - no nix package with full integration
    # signal-desktop, tailscale, obs-studio
  ];

  users.users."wantguns" = {
    shell = pkgs.zsh;
    home = "/Users/wantguns";
    packages = with pkgs; [
      wget
      k9s
      kubectl
      kubernetes-helm
      xh
      jq
      yq-go
      mosh
      shadowsocks-rust
      # dpkg
      typst
      terraform
      poppler-utils
      tree
      awscli2
      ssm-session-manager-plugin
      pgcli
      rclone
      bat
      kubecm
      colorized-logs
      gh
      dive
      pwgen
      postgresql
      redis
      hyperfine
      htop
      gnumake
      jujutsu
      golangci-lint
      # ollama
      graphviz
      scrcpy
      pnpm
      fd
      grpcurl
      ocrmypdf
      clusterctl
      kind
      tilt
      kubebuilder
      zola
      protobuf
      protoc-gen-go
      protoc-gen-go-grpc

      go
      python312
      python312Packages.pyyaml
      pipx
      nodejs_22
      lua
      luarocks
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
