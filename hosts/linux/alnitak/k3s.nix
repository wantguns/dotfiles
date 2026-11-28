{
  config,
  pkgs,
  lib,
  inputs,
  ...
}:
{
  networking.firewall = {
    allowedTCPPorts = [
      80
      443
      6443 # kube-apiserver
      4244 # required by hubble-peer
      10250 # metrics server
    ];
    allowedUDPPorts = [
      8472 # cilium vxlan
    ];
    checkReversePath = false;
    trustedInterfaces = [
      "cilium_host"
      "cilium_net"
      "cilium_vxlan"
      "lxc*"
      "wg_orion"
    ];

    extraInputRules = ''
      ip saddr 10.69.0.0/16 accept
      ip saddr 10.42.0.0/16 accept
      ip saddr 10.43.0.0/16 accept
    '';

    extraCommands = ''
      # by default the packets originating from the pod and the service cidrs with this dst were dropping
      iptables -A nixos-fw -s 10.42.0.0/16 -d 10.69.0.1 -j nixos-fw-accept
      iptables -A nixos-fw -s 10.43.0.0/16 -d 10.69.0.1 -j nixos-fw-accept
    '';
  };

  services.k3s = {
    enable = true;
    role = "server";
    clusterInit = true;
    extraFlags = toString [
      "--flannel-backend=none"
      "--disable-kube-proxy"
      "--disable-network-policy"
      "--disable servicelb"
      "--disable traefik"
      "--node-ip=10.69.0.1"
      "--node-external-ip=78.46.83.190"
      "--node-label openebs.io/nodeid=alnitak"
      "--debug"
    ];
  };
}
