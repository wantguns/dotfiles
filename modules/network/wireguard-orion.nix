{
  lib,
  config,
  orion,
  thisHostName,
  ...
}:

let
  inherit (lib) mkIf mkOption types;

  cfg = config.services.orionWireguard;
  wgIf = cfg.interfaceName;
  listenPort = 51820;
  overlayPrefixLen = 16;

  me = orion.${thisHostName};
  isHub = me ? endpoint;
  cidr = peer: "${peer.address}/32";
  spokesOf = hub: lib.filter (peer: (peer.hub or null) == hub) (lib.attrValues orion);

  peerFor =
    name: peer:
    if !isHub then
      lib.optionalAttrs (name == me.hub) {
        Endpoint = "${peer.endpoint}:${toString listenPort}";
        PersistentKeepalive = 25;
        PublicKey = peer.publicKey;
        AllowedIPs = [ "10.69.0.0/${toString overlayPrefixLen}" ];
      }
    else if peer ? endpoint then
      {
        Endpoint = "${peer.endpoint}:${toString listenPort}";
        PublicKey = peer.publicKey;
        AllowedIPs = [ (cidr peer) ] ++ map cidr (spokesOf name);
      }
    else
      lib.optionalAttrs (peer.hub == thisHostName) {
        PersistentKeepalive = 25;
        PublicKey = peer.publicKey;
        AllowedIPs = [ (cidr peer) ];
      };

  wireguardPeers = lib.filter (peer: peer != { }) (
    lib.mapAttrsToList peerFor (removeAttrs orion [ thisHostName ])
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
        assertion = orion ? ${thisHostName};
        message = "Host ${thisHostName} is not in the orion table in flake.nix.";
      }
    ];

    networking.useNetworkd = true;
    systemd.network.enable = true;

    networking.firewall.allowedUDPPorts = mkIf isHub [ listenPort ];

    boot.kernel.sysctl."net.ipv4.ip_forward" = mkIf isHub 1;

    systemd.network.netdevs."50-${wgIf}" = {
      netdevConfig = {
        Name = wgIf;
        Kind = "wireguard";
      };
      wireguardConfig = {
        PrivateKeyFile = config.sops.secrets."wg/${thisHostName}/private".path;
        ListenPort = mkIf isHub listenPort;
      };
      inherit wireguardPeers;
    };

    systemd.network.networks."50-${wgIf}" = {
      matchConfig.Name = wgIf;
      address = [ "${me.address}/${toString overlayPrefixLen}" ];
      networkConfig.IPv4Forwarding = mkIf isHub true;
    };
  };
}
