{ config, pkgs, ... }:
{
  networking.hostName = "together";

  # Homebrew strips Nix paths, so it cannot find gh to authenticate private taps.
  system.activationScripts.preActivation.text = ''
    sudo --user=${config.homebrew.user} --set-home /bin/sh -c 'umask 077; mkdir -p ~/.homebrew; t=$(${pkgs.gh}/bin/gh auth token) && printf "HOMEBREW_GITHUB_API_TOKEN=%s\n" "$t" > ~/.homebrew/brew.env' || echo "warning: no gh token for Homebrew" >&2
  '';
  system.activationScripts.postActivation.text = ''
    rm -f ~${config.homebrew.user}/.homebrew/brew.env
  '';

  homebrew = {
    enable = true;
    user = "wantguns";

    greedyCasks = true;
    onActivation = {
      autoUpdate = true;
      upgrade = true;
      cleanup = "zap";
    };

    taps = [
      {
        name = "togethersecured/abacus";
        clone_target = "https://github.com/togethersecured/abacus";
        trusted = true;
      }
    ];
    brews = [
      "togethersecured/abacus/abacus"
    ];

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
      _1password-cli
      typst
      scdoc
      codespell
      mtr
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
