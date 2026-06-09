{
  config,
  pkgs,
  lib,
  inputs,
  ...
}:

{
  imports = [
    ./k3s.nix
  ];

  boot = {
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
      efi.efiSysMountPoint = "/boot";
    };
  };

  time.timeZone = "Asia/Kolkata";

  networking = {
    hostName = "bellatrix";
    nameservers = [
      "1.1.1.1"
      "8.8.8.8"
    ];

    firewall = {
      allowedTCPPorts = [
        8388 # shadowsocks
        6969 # forwarded port
        6970 # forwarded port
      ];
      checkReversePath = "loose";
    };
  };

  # Prevent lockups
  systemd.network.wait-online.enable = false;

  programs.zsh.enable = true;

  users.users.wantguns = {
    isNormalUser = true;
    extraGroups = [
      "wheel"
      "networkmanager"
      "docker"
    ];
    shell = pkgs.zsh;
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHcueIcj4fgzD6cUUGqituoupjexNNF1Hjrr+dyJ+gvA gunwant.jain@C02GH2V9MD6M.local"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINMm/9RWSPMxyeMHglw6cyZBgtuke+7l5wc9dXmQkiii"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIIA5UkkDnsE/Td4aa0N+2pZ05xAHvPE8SMVk5zlHhxA"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAN+U9xlrIVyWY7DzhMO6Tf+JN04a9nzcdMc7nLOnWqq wantguns@mintaka"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMQ0qLuDtERCe8zPmAOfJjJzENQl8SJURTwqZnXfdGsn wantguns@alnitak"
    ];

    packages = with pkgs; [
      shadowsocks-rust
    ];
  };

  services = {
    resolved = {
      enable = true;
      settings.Resolve = {
        DNSSEC = "allow-downgrade";
        FallbackDNS = [
          "1.1.1.1"
          "8.8.8.8"
        ];
      };
    };

    openssh = {
      enable = true;
      settings = {
        GatewayPorts = "yes";
      };
    };
  };

  hardware = {
    enableRedistributableFirmware = true;
  };
  programs.mosh.enable = true;

  sops.secrets."wg/bellatrix/private" = {
    owner = "root";
    group = "systemd-network";
    mode = "0640";
    restartUnits = [ "systemd-networkd.service" ];
  };

  system.stateVersion = "24.11";
}
