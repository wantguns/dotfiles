{ config, pkgs, ... }: {
  nix = { settings = { "ssl-cert-file" = "/opt/nix-and-zscaler.crt"; }; };

  environment.systemPackages = with pkgs; [ termshark ];

  users.users."gunwant.jain1" = {
    shell = pkgs.zsh;
    home = "/Users/gunwant.jain1";
    packages = with pkgs; [
      feishin
      termshark
      xh
      jq
      clang-tools
      zig
      sops
      gnupg
      net-news-wire
      redis
      postgresql_17
      qpdf
      nodejs_23
      tree
      zola
    ];
  };

  homebrew = {
    enable = true;
    # onActivation = {
    #     autoUpdate = true;
    #     cleanup = "uninstall";
    #     upgrade = true;
    # };
    brews = [
      "k9s"
      "kubectl"
      "go"
      "htop"
      "typst"
      "rclone"
      "helm"
      "shadowsocks-rust"
    ];

    # casks = [
    #   "netnewswire"
    #   "submariner"
    # ];
  };
}
