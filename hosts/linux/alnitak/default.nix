{ config, pkgs, lib, inputs, ... }:

{
  imports = [
    ./k3s.nix
  ];

  boot = {
    supportedFilesystems = [ "zfs" ];
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
      efi.efiSysMountPoint = "/boot";
    };
  };

  # These parameters prevent lock ups
  systemd.network.wait-online.enable = false;
  fileSystems."/home".options = [ "noauto" ];
  fileSystems."/media".options = [ "noauto" ];
  fileSystems."/backups".options = [ "noauto" ];

  networking = {
    hostId = "98e1d0eb";
    hostName = "alnitak";
    nameservers = [ "1.1.1.1" ];
  };

  programs.zsh.enable = true;

  users.users.wantguns = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" "docker" ];
    shell = pkgs.zsh;
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHcueIcj4fgzD6cUUGqituoupjexNNF1Hjrr+dyJ+gvA gunwant.jain@C02GH2V9MD6M.local"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINMm/9RWSPMxyeMHglw6cyZBgtuke+7l5wc9dXmQkiii"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIIA5UkkDnsE/Td4aa0N+2pZ05xAHvPE8SMVk5zlHhxA"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAN+U9xlrIVyWY7DzhMO6Tf+JN04a9nzcdMc7nLOnWqq wantguns@mintaka"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIZXnfEw3pyp3l0hAtdjExzZBlzIzFY12L1kMI3ckF0c wantguns@bellatrix"
    ];
  };

  services = {
    resolved = {
      enable = true;
      dnssec = "allow-downgrade";
      fallbackDns = [ "1.1.1.1" "8.8.8.8" ];
    };
  };

  hardware = { enableRedistributableFirmware = true; };
  environment.systemPackages = with pkgs;
  [
    rclone
    kubectl
    k9s
    fluxcd
    cilium-cli
    jq
    kubernetes-helm
  ];

  system.stateVersion = "24.11";
}
