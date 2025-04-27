{ config, pkgs, lib, inputs, ... }:
{
   # adding some extra modules for better cilium support
  boot.kernelModules = [ "br_netfilter" "ip_conntrack" "ip_vs" "ip_vs_rr" "ip_vs_wrr" "ip_vs_sh" "overlay" ];  

  networking.firewall = {
    allowedTCPPorts = [
      6443 # apiserver
      2379 # ha etcd clients
      2380 # ha etcd peers
      10250 # metrics-server
    ];
    checkReversePath = "loose";
    trustedInterfaces = [
      "cilium_host"
      "cilium_net"
      "cilium_vxlan"
      "lxc*"
    ];
  };

  services.k3s = {
    enable = false;
    role = "agent";
    tokenFile = "/run/secrets/k3s/agent_token";
    serverAddr = "https://78.46.83.190:6443";
    extraFlags = toString [
      "--node-ip=10.0.0.78"
      "--node-external-ip=152.67.6.204"
      "--debug"
    ];
  };

  # sops.secrets."k3s/agent_token" = {};
}
