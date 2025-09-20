{ lib
, config
, pkgs
, hosts
, thisHostName
, ...
}:

let
  inherit (lib) mkIf filterAttrs attrValues mapAttrs mkOption types;
  thisHost = hosts.${thisHostName};

  cfg = config.services.orionWireguard;

  wgIf = cfg.interfaceName;
  listenPort = 51820;
  overlayPrefixLen = 16;
  isPublic = thisHost.ips ? public;

  otherPeers = filterAttrs (n: v: n != thisHostName && v ? ips && v.ips ? orion) hosts;

  wireguardPeers =
    attrValues (mapAttrs (_n: v:
      let
        peerWG = v.ips.orion.address;
        peerEndpoint =
          if v.ips ? public then "${v.ips.public}:${toString listenPort}" else null;
        persistentKeepalive =
          if (!isPublic && v.ips ? public) || (isPublic && ! (v.ips ? public))
          then 25 else null;
      in lib.filterAttrs (_: val: val != null) {
        PublicKey = v.ips.orion.publicKey;
        AllowedIPs = [ "${peerWG}/32" ];
        Endpoint = peerEndpoint;
        PersistentKeepalive = persistentKeepalive;
      }
    ) otherPeers);

in
{
  options.services.orionWireguard = {
    interfaceName = mkOption {
      type = types.str;
      default = "wg_orion";
      description = "Name of the WireGuard interface.";
    };
  };

  config = {
    assertions = [
      {
        assertion =
          (thisHost ? ips)
          && (thisHost.ips ? orion)
          && (thisHost.ips.orion ? address)
          && (thisHost.ips.orion ? publicKey)
          && (thisHost.ips.orion ? privateKeyFile);
        message = "Host ${thisHostName}: missing one of ips.orion.{address,publicKey,privateKeyFile}.";
      }
    ];

    networking.useNetworkd = true;
    systemd.network.enable = true;

    networking.firewall.allowedUDPPorts = mkIf isPublic [ listenPort ];

    boot.kernel.sysctl."net.ipv4.ip_forward" = 1;

    systemd.network.netdevs."50-${wgIf}" = {
      netdevConfig = {
        Name = wgIf;
        Kind = "wireguard";
      };
      wireguardConfig = {
        PrivateKeyFile = thisHost.ips.orion.privateKeyFile;
        ListenPort = mkIf isPublic listenPort;
      };
      wireguardPeers = wireguardPeers;
    };

    systemd.network.networks."50-${wgIf}" = {
      matchConfig.Name = wgIf;
      address = [ "${thisHost.ips.orion.address}/${toString overlayPrefixLen}" ];
      networkConfig.IPv4Forwarding = true;
    };
  };
}
