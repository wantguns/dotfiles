{ config, pkgs, lib, inputs, ... }:

{
  boot = {
    supportedFilesystems = [ "zfs" ];
    zfs.requestEncryptionCredentials = false;
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
      efi.efiSysMountPoint = "/boot";
    };
  };

  # see: https://github.com/nix-community/disko/issues/581#issuecomment-2024231487
  fileSystems."/home".options = [ "noauto" ];

  networking = {
    hostName = "mintaka";
    hostId = "30daa5e6";
    interfaces = {
      enp2s0.ipv6.addresses = [{
        address = "192.168.1.130";
        prefixLength = 32;
      }];
    };
    nameservers = [ "1.1.1.1" "8.8.8.8" ];
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

  sops.secrets."wg/mintaka/private" = { };

  system.stateVersion = "24.11";
}
