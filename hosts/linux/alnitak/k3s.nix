{
  config,
  pkgs,
  lib,
  inputs,
  ...
}:
let
  gatewayApiCrds = pkgs.fetchurl {
    url = "https://github.com/kubernetes-sigs/gateway-api/releases/download/v1.4.0/standard-install.yaml";
    sha256 = "sha256-akAp5mFEbWSt2GagDs3EDBQhm2h3erYUxc2qwK20gfE=";
  };
in
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

    manifests = {
      gateway-api = {
        source = gatewayApiCrds;
      };
    };

    autoDeployCharts = {
      cilium = {
        name = "cilium";
        repo = "https://helm.cilium.io";
        version = "1.18.2";
        hash = "sha256-ObYqcvCJLdFlSL0I7pfV2y6XX3wfVxVVeKFEGG4imS8=";
        targetNamespace = "kube-system";
        createNamespace = false;
        extraFieldDefinitions.spec.bootstrap = true;
        values = {
          operator = {
            replicas = 1;
          };

          k8sServiceHost = "10.69.0.1";
          k8sServicePort = "6443";
          routingMode = "tunnel";
          tunnelPort = 8472;
          autoDirectNodeRoutes = false;
          kubeProxyReplacement = true;

          ipam = {
            mode = "kubernetes";
          };

          gatewayAPI = {
            enabled = true;
            hostNetwork = {
              enabled = true;
            };
          };

          hubble = {
            enabled = true;
            relay = {
              enabled = true;
            };
            ui = {
              enabled = true;
            };
          };

          envoy = {
            securityContext = {
              capabilities = {
                keepCapNetBindService = true;
                envoy = [
                  "NET_ADMIN"
                  "SYS_ADMIN"
                  "NET_BIND_SERVICE"
                ];
              };
            };
          };
        };
      };

      argocd = {
        name = "argo-cd";
        repo = "https://argoproj.github.io/argo-helm";
        version = "9.0.5";
        hash = "sha256-Vm42yonj7KPyV1derzzfAFjzBEiSXUmkFROO4CPJk5w=";
        targetNamespace = "argocd";
        createNamespace = true;
        extraDeploy = [
          ./manifests/argo-resources.yaml
        ];
        values = {
          configs = {
            params = {
              "server.insecure" = true;
            };
            cm = {
              "timeout.reconciliation" = "60s";
            };
          };
        };
      };
    };
  };
}
