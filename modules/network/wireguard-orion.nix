{
  lib,
  config,
  pkgs,
  hosts,
  thisHostName,
  ...
}:

let
  inherit (lib)
    mkIf
    filterAttrs
    attrValues
    mapAttrs
    mkOption
    types
    head
    ;
  thisHost = hosts.${thisHostName};

  cfg = config.services.orionWireguard;

  wgIf = cfg.interfaceName;
  listenPort = 51820;
  overlayPrefixLen = 16;
  isPublic = thisHost.ips ? public;

  allPeers = hosts;
  otherPeers = filterAttrs (n: _: n != thisHostName) allPeers;

  wireguardPeers =
    let
      publicPeers = filterAttrs (_: v: v.ips ? public) otherPeers;
      gatewayHostname =
        if thisHost.ips.orion ? gateway then
          thisHost.ips.orion.gateway
        else
          (head (lib.attrNames publicPeers));
    in
    attrValues (
      mapAttrs (
        _peerName: peer:
        if !(peer ? ips && peer.ips ? orion) then
          null
        else
          let
            peerWGAddress = peer.ips.orion.address;
            isPeerPublic = peer.ips ? public;

            endpoint = if isPeerPublic then "${peer.ips.public}:${toString listenPort}" else null;
            persistentKeepalive = if isPublic != isPeerPublic then 25 else null;

            allowedIPs =
              if isPublic then
                [ "${peerWGAddress}/32" ]
              else if isPeerPublic then
                if peer.hostname == gatewayHostname then [ "10.69.0.0/16" ] else [ "${peerWGAddress}/32" ]
              else
                null;

          in
          if allowedIPs == null then
            null
          else
            (lib.filterAttrs (_: val: val != null) {
              Endpoint = endpoint;
              PersistentKeepalive = persistentKeepalive;
              PublicKey = peer.ips.orion.publicKey;
              AllowedIPs = allowedIPs;
            })
      ) otherPeers
    );
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
      wireguardPeers = lib.filter (p: p != null) wireguardPeers;
    };

    systemd.network.networks."50-${wgIf}" = {
      matchConfig.Name = wgIf;
      address = [ "${thisHost.ips.orion.address}/${toString overlayPrefixLen}" ];
      networkConfig.IPv4Forwarding = true;
    };
  };
}
