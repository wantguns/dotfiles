{ config, pkgs, ... }:
{
  networking.hostName = "together";

  environment.systemPackages = with pkgs; [
    rectangle
  ];

  homebrew = {
    enable = true;
    user = "wantguns";

    casks = [
      "linear"
      "notion"
      "okta-verify"
      "finicky"
      "google-chrome"
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
      awscli2
      colima
      docker-client
      docker-credential-helpers
      pgcli
      gh
      redis
      gettext
      gomplate
      kubernetes-controller-tools
      trunk-io
      # GNU sed exposed as `gsed`
      (runCommand "gsed" { } ''
        mkdir -p $out/bin
        ln -s ${gnused}/bin/sed $out/bin/gsed
      '')
      rustscan
      openfortivpn
      shadowsocks-rust
      xray
      argocd
      kubevirt
      netbird
      netbird-ui
      jujutsu
    ];
  };


  security.pam.services.sudo_local.touchIdAuth = true;

  launchd.daemons.netbird = {
    serviceConfig = {
      ProgramArguments = [
        "/bin/sh"
        "-c"
        "mkdir -p /var/run/netbird /var/lib/netbird && exec ${pkgs.netbird}/bin/netbird service run"
      ];
      RunAtLoad = true;
      KeepAlive = true;
    };
  };
}
