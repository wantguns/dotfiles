{ config, pkgs, ... }:
{
  imports = [ ./abacus.nix ];

  networking.hostName = "together";

  homebrew = {
    enable = true;
    user = "wantguns";

    greedyCasks = true;
    onActivation = {
      autoUpdate = true;
      upgrade = true;
      cleanup = "zap";
    };

    casks = [
      "rectangle"
      "okta-verify"
      "finicky"
      "google-chrome"
      "slack"
      "discord"
      "spotify"
      "signal"
      "zoom"
      "jellyfin-media-player"
      "openshot-video-editor"
      "obs"
      "iina"
      "granola"
      "mactoy"
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
      jujutsu
      argo-workflows
      (buildGoModule rec {
        pname = "argocd-agentctl";
        version = "0.10.0";
        src = fetchFromGitHub {
          owner = "argoproj-labs";
          repo = "argocd-agent";
          rev = "v${version}";
          hash = "sha256-Jg9AuVQ+FyFO86vEEVztbIOMowl9NTdbEY/UJsjs4M4=";
        };
        vendorHash = "sha256-2swgVy+RxsmYGFZoVQTz5T4a8eOhexaIorfNSfl780o=";
        subPackages = [ "cmd/ctl" ];
        postInstall = "mv $out/bin/ctl $out/bin/argocd-agentctl";
      })
      _1password-cli
      typst
      scdoc
      codespell
      mtr
      kubelogin-oidc
      kubeseal
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
