{
  config,
  pkgs,
  lib,
  inputs,
  ...
}:

{
  imports = [
    "${inputs.self}/modules/desktop"
    inputs.lanzaboote.nixosModules.lanzaboote
  ];

  boot = {
    supportedFilesystems = [ "zfs" ];
    zfs.forceImportRoot = false;
    zfs.requestEncryptionCredentials = false;
    loader = {
      systemd-boot.enable = lib.mkForce false;
      efi.canTouchEfiVariables = true;
      efi.efiSysMountPoint = "/boot";
      timeout = 5;
    };
    lanzaboote = {
      enable = true;
      pkiBundle = "/var/lib/sbctl";
      configurationLimit = 5;
    };
  };

  # see: https://github.com/nix-community/disko/issues/581#issuecomment-2024231487
  fileSystems."/home".options = [ "noauto" ];
  # prevent lockups while switching to a new iteration
  systemd.network.wait-online.enable = false;

  networking = {
    hostName = "rigel";
    hostId = "7a3b9f12";
    firewall = {
      checkReversePath = false;
      trustedInterfaces = [ "wg_orion" ];
      extraInputRules = ''
        ip saddr 10.69.0.0/16 accept
      '';
    };
  };

  time.timeZone = "Asia/Kolkata";

  desktop.compositor = "niri";

  programs.zsh.enable = true;

  users.users.wantguns = {
    isNormalUser = true;
    extraGroups = [
      "wheel"
      "networkmanager"
    ];
    shell = pkgs.zsh;
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIZXnfEw3pyp3l0hAtdjExzZBlzIzFY12L1kMI3ckF0c wantguns@bellatrix"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMQ0qLuDtERCe8zPmAOfJjJzENQl8SJURTwqZnXfdGsn wantguns@alnitak"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAN+U9xlrIVyWY7DzhMO6Tf+JN04a9nzcdMc7nLOnWqq wantguns@mintaka"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDDNUwRuKNdF4ry5+JRhOs6I1wSOk6a+xqkfrfZUXSUz wantguns@together"
    ];
  };

  services = {
    fwupd.enable = true;

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

  hardware.enableRedistributableFirmware = true;
  hardware.cpu.amd.updateMicrocode = true;

  environment.systemPackages = with pkgs; [
    wireguard-tools
    sbctl
  ];

  sops.secrets = {
    "wg/rigel/private" = {
      owner = "root";
      group = "systemd-network";
      mode = "0640";
      restartUnits = [ "systemd-networkd.service" ];
    };
  };

  system.stateVersion = "26.05";
}
