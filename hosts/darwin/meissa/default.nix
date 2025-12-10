{ config, pkgs, ... }: {
  networking.hostName = "meissa";
  environment.systemPackages = with pkgs; [
    raycast
    obsidian
    spotify
    feishin
    rectangle
    notion-app
    localsend
    iina
    google-chrome
    halloy
    yaak

    # block of shame - no nix package with full integration
    # signal-desktop, tailscale, obs-studio
  ];

  homebrew = {
    enable = true;
    user = "wantguns";

    taps = [];
    brews = [
        "firefoxpwa"
    ];
    casks = [
        "firefox"
        "slack"
        "discord"
        "screen-studio"
        "inkscape"
    ];
};

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
      kubeseal
      ruff
      buf
      opencode
      cloc
      kubectl-cnpg
      rustc
      cargo
      rust-analyzer
      diesel-cli
      restic
      zig
      kafkactl

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
