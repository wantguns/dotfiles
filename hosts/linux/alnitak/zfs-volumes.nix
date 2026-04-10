{ config, pkgs, ... }:

{
  sops.secrets."zfs/alnitak-mediapool-shared-encrypted" = {};

  systemd.services.ensure-mediapool-encrypted = {
    description = "Ensure mediapool/media-encrypted exists and key is loaded";
    wantedBy = [ "multi-user.target" ];
    before = [ "zfs-mount.service" ];
    after = [
      "zfs-import.target"
      "sops-nix.service"
    ];
    requires = [ "zfs-import.target" ];
    wants = [ "sops-nix.service" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
    script = ''
      ZFS="${pkgs.zfs}/bin/zfs"

      if ! $ZFS list mediapool/media-encrypted &>/dev/null; then
        $ZFS create \
          -o encryption=on \
          -o keyformat=hex \
          -o keylocation=file:///run/secrets/zfs/alnitak-mediapool-shared-encrypted \
          -o compression=lz4 \
          -o atime=off \
          -o mountpoint=legacy \
          mediapool/media-encrypted
        echo "Created mediapool/media-encrypted"
      else
        keystatus=$($ZFS get -H -o value keystatus mediapool/media-encrypted)
        if [ "$keystatus" = "unavailable" ]; then
          $ZFS load-key mediapool/media-encrypted
          echo "Loaded key for mediapool/media-encrypted"
        else
          echo "Key already loaded"
        fi
      fi
    '';
  };
}
