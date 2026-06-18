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
    ./xray.nix
    ./zfs-volumes.nix
  ];

  boot = {
    supportedFilesystems = [ "zfs" ];
    zfs.forceImportRoot = false;
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
      efi.efiSysMountPoint = "/boot";
    };
  };

  # These parameters prevent lock ups
  systemd.network.wait-online.enable = false;
  fileSystems."/home".options = [ "noauto" ];

  # Mount legacy zfs pool
  fileSystems."/media" = {
    device = "mediapool/media";
    fsType = "zfs";
  };
  fileSystems."/backups" = {
    device = "mediapool/backups";
    fsType = "zfs";
  };

  networking = {
    hostId = "98e1d0eb";
    hostName = "alnitak";
    nameservers = [ "1.1.1.1" ];
    useDHCP = false;

    interfaces = {
      enp0s31f6 = {
        ipv4.addresses = [
          {
            address = "78.46.83.190";
            prefixLength = 32;
          }
        ];
        ipv6.addresses = [
          {
            address = "fe80::7165:daea:8bc3:9f16";
            prefixLength = 64;
          }
        ];
      };
    };

    defaultGateway = {
      address = "78.46.83.161";
      interface = "enp0s31f6";
      source = "78.46.83.190";
      metric = 100;
    };
    defaultGateway6 = {
      address = "fe80::1";
      interface = "enp0s31f6";
      source = "fe80::7165:daea:8bc3:9f16";
      metric = 100;
    };
  };

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
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIZXnfEw3pyp3l0hAtdjExzZBlzIzFY12L1kMI3ckF0c wantguns@bellatrix"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDDNUwRuKNdF4ry5+JRhOs6I1wSOk6a+xqkfrfZUXSUz wantguns@together"
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
  };

  hardware = {
    enableRedistributableFirmware = true;
  };
  programs.mosh.enable = true;
  environment.systemPackages = with pkgs; [
    rclone
    kubectl
    k9s
    cilium-cli
    jq
    kubernetes-helm
    htop
    nerdctl
    dig
    iperf
    wget
    python3
    uv
    pwru
    restic
  ];

  sops.secrets = {
    "wg/alnitak/private" = {
      owner = "root";
      group = "systemd-network";
      mode = "0640";
      restartUnits = [ "systemd-networkd.service" ];
    };
  };

  system.stateVersion = "24.11";
}
