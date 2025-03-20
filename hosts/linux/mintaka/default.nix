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

  networking = {
    hostName = "mintaka";
    hostId = "30daa5e6";
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

  hardware = {
    enableRedistributableFirmware = true;
  };

  system.stateVersion = "24.11";
}
