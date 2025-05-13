{
  disko.devices = {
    disk = {
      nvme = {
        type = "disk";
        device = "/dev/nvme0n1";
        content = {
          type = "gpt";
          partitions = {
            boot = {
              size = "1G";
              type = "EF00"; # EFI System Partition
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot";
              };
            };
            zfs = {
              size = "100%";
              content = {
                type = "zfs";
                pool = "fastpool";
              };
            };
          };
        };
      };

      sda = {
        type = "disk";
        device = "/dev/sda";
        content = {
          type = "gpt";
          partitions = {
            zfs = {
              size = "100%";
              content = {
                type = "zfs";
                pool = "mediapool";
              };
            };
          };
        };
      };

      sdb = {
        type = "disk";
        device = "/dev/sdb";
        content = {
          type = "gpt";
          partitions = {
            zfs = {
              size = "100%";
              content = {
                type = "zfs";
                pool = "mediapool";
              };
            };
          };
        };
      };
    };

    zpool = {
      fastpool = {
        type = "zpool";
        mode = "";
        options = {
          ashift = "12";
          autotrim = "on";
        };
        rootFsOptions = {
          compression = "lz4";
          acltype = "posixacl";
          atime = "off";
          xattr = "sa";
        };

        datasets = {
          "root" = {
            type = "zfs_fs";
            mountpoint = "/";
          };
          "nix" = {
            type = "zfs_fs";
            mountpoint = "/nix";
            options = {
              compression = "zstd";
              recordsize = "64K";
            };
          };
          "home" = {
            type = "zfs_fs";
            mountpoint = "/home";
          };
          "var" = {
            type = "zfs_fs";
            mountpoint = "/var";
          };
          "var/log" = {
            type = "zfs_fs";
            mountpoint = "/var/log";
          };
        };
      };

      mediapool = {
        type = "zpool";
        mode = "mirror";
        options = {
          ashift = "12";
          autotrim = "off";
        };

        rootFsOptions = {
          compression = "lz4";
          atime = "off";
        };
        datasets = {
          "media" = {
            type = "zfs_fs";
            mountpoint = "/media";
            options.mountpoint = "legacy";
          };
          "backups" = {
            type = "zfs_fs";
            mountpoint = "/backups";
            options = {
              mountpoint = "legacy";
              compression = "zstd";
              recordsize = "1M";
              copies = "1";
            };
          };
        };
      };
    };
  };
}
