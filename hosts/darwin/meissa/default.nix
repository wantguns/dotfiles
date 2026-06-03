{ config, pkgs, ... }: {
  networking.hostName = "meissa";
  environment.systemPackages = with pkgs; [
    raycast
    obsidian
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

    taps = [
        "fastrepl/hyprnote"
    ];
    brews = [
        "firefoxpwa"
        "coreutils"
    ];
    casks = [
        "firefox"
        "slack"
        "discord"
        "screen-studio"
        "inkscape"
        "hyprnote"
        "spotify"
        "helium-browser"
        "calibre"
    ];
};

  users.users."wantguns" = {
    shell = pkgs.zsh;
    home = "/Users/wantguns";
    packages = with pkgs; [
      wget
      k9s
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
      # pgcli
      rclone
      bat
      kubecm
      colorized-logs
      gh
      dive
      # pwgen
      postgresql
      redis
      hyperfine
      htop
      gnumake
      jujutsu
      golangci-lint
      gopls
      # ollama
      graphviz
      scrcpy
      pnpm
      fd
      curl
      grpcurl
      # ocrmypdf
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
      cloc
      kubectl-cnpg
      rustc
      cargo
      rust-analyzer
      diesel-cli
      restic
      zig
      kafkactl
      xray
      cue
      autossh
      nfpm
      lima
      gnupg
      wrk
      ncdu
      ffmpeg
      zellij
      nmap
      pi-coding-agent

      go
      python312
      python312Packages.pyyaml
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
