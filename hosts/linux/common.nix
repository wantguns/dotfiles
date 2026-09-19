{
  config,
  pkgs,
  lib,
  ...
}:

{
  sops.defaultSopsFile = ../../secrets/hosts.yaml;
  sops.age.keyFile = "/var/lib/sops-nix/key.txt";
  sops.age.generateKey = true;

  networking = {
    networkmanager.enable = true;
    firewall = {
      enable = true;
      allowedTCPPorts = [ 22 ];
    };
  };

  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = false;
      PermitRootLogin = "no";
    };
  };

  users.users.wantguns.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMQ0qLuDtERCe8zPmAOfJjJzENQl8SJURTwqZnXfdGsn wantguns@alnitak"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIZXnfEw3pyp3l0hAtdjExzZBlzIzFY12L1kMI3ckF0c wantguns@bellatrix"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAN+U9xlrIVyWY7DzhMO6Tf+JN04a9nzcdMc7nLOnWqq wantguns@mintaka"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIO+/xFhcRE1yok1XSvG2G6kc8cqaTgKQq45IfubZ9hMG wantguns@rigel"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDDNUwRuKNdF4ry5+JRhOs6I1wSOk6a+xqkfrfZUXSUz wantguns@together"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOnYnZfddsSHguC/HhSAhGyj28jFJjAOZm3R8hL2Xigo wantguns@together"
  ];

  nix = {
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 30d";
    };
    settings = {
      auto-optimise-store = true;
      experimental-features = [
        "nix-command"
        "flakes"
      ];
      trusted-users = [
        "root"
        "@wheel"
      ];
    };
  };

  security.sudo.wheelNeedsPassword = false;
  i18n.defaultLocale = "en_US.UTF-8";
}
