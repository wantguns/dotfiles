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
  ];

  boot = {
    supportedFilesystems = [ "zfs" ];
    zfs.forceImportRoot = false;
    zfs.requestEncryptionCredentials = false;
    loader = {
      systemd-boot.enable = true;
      systemd-boot.configurationLimit = 5;
      efi.canTouchEfiVariables = true;
      efi.efiSysMountPoint = "/boot";
      timeout = 5;
    };
  };

  # see: https://github.com/nix-community/disko/issues/581#issuecomment-2024231487
  fileSystems."/home".options = [ "noauto" ];
  # prevent lockups while switching to a new iteration
  systemd.network.wait-online.enable = false;

  networking = {
    hostName = "betelgeuse";
    hostId = "6bd18782";
    firewall = {
      checkReversePath = false;
      trustedInterfaces = [ "wg_orion" ];
      extraInputRules = ''
        ip saddr 10.69.0.0/16 accept
      '';
    };
  };

  time.timeZone = "Europe/Amsterdam";

  desktop.compositor = "niri";

  programs.zsh.enable = true;

  users.users.wantguns = {
    isNormalUser = true;
    extraGroups = [
      "wheel"
      "networkmanager"
    ];
    shell = pkgs.zsh;
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
    "wg/betelgeuse/private" = {
      owner = "root";
      group = "systemd-network";
      mode = "0640";
      restartUnits = [ "systemd-networkd.service" ];
    };
  };

  system.stateVersion = "26.11";
}
