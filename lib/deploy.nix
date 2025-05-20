{ pkgs, nixpkgs }:

pkgs.writeShellScriptBin "deploy" ''
  #!/usr/bin/env bash
  set -e

  RAW_HOSTNAME=''${1:-$(hostname)}
  HOSTNAME=$(echo "$RAW_HOSTNAME" | cut -d '.' -f 1)
  REMOTE_BUILD=''${2:-false}

  SYSTEM=$(nix eval --raw .#hosts."$HOSTNAME".system)
  USERNAME=$(nix eval --raw .#hosts."$HOSTNAME".username)
  JUST_HOME=$(nix eval --json .#hosts."$HOSTNAME".justHome 2>/dev/null | grep -q "true" && echo "true" || echo "false")
  REMOTE_BUILD_ENABLED=$(nix eval --json .#hosts."$HOSTNAME".remoteBuild | grep -q "true" && echo "true" || echo "false")

  deploy_home() {
    local host=$1
    local remote=$2
    echo "Deploying home configuration for $host..."

    if [ "$remote" == "true" ]; then
      ssh "$USERNAME@$IP" "nix run 'github:nix-community/home-manager/master' -- switch --flake '.#$host'"
    else
      nix run github:nix-community/home-manager/master -- switch --flake .#"$host"
    fi
  }

  if [[ "$REMOTE_BUILD" == "true" && "$REMOTE_BUILD_ENABLED" == "true" ]]; then
    PUBLIC_IP=$(nix eval --raw .#hosts."$HOSTNAME".ips.public 2>/dev/null || echo "")
    PRIVATE_IP=$(nix eval --raw .#hosts."$HOSTNAME".ips.private 2>/dev/null || echo "")

    IP="$PUBLIC_IP"
    if ! ping -c 1 -W 1 "$IP" &>/dev/null && [ -n "$PRIVATE_IP" ]; then
      IP="$PRIVATE_IP"
    fi

    if [ -z "$IP" ]; then
      echo "Error: No IP address available for remote build"
      exit 1
    fi

    if [[ "$JUST_HOME" == "true" ]]; then
      deploy_home "$HOSTNAME" true
    else
      echo "Deploying to $HOSTNAME ($IP) with remote build..."
    
      if [[ "$SYSTEM" == *"-linux" ]]; then
        nix run nixpkgs#nixos-rebuild -- switch \
          --flake .#"$HOSTNAME" \
          --build-host "$USERNAME@$IP" \
          --target-host "$USERNAME@$IP" \
          --use-remote-sudo \
          --fast \
          --use-substitutes \
          --option builders-use-substitutes true
      else
        sudo nix run github:lnl7/nix-darwin/master#darwin-rebuild -- switch \
          --flake .#"$HOSTNAME" \
          --build-host "root@$IP" \
          --target-host "root@$IP" \
          --fast
      fi
    fi
  else
    if [[ "$JUST_HOME" == "true" ]]; then
      deploy_home "$HOSTNAME" false
    else
      echo "Deploying to $HOSTNAME locally..."
    
      if [[ "$SYSTEM" == *"-linux" ]]; then
        sudo nix run nixpkgs#nixos-rebuild -- switch --flake .#"$HOSTNAME"
      else
        nix run github:lnl7/nix-darwin/master#darwin-rebuild -- switch --flake .#"$HOSTNAME"
      fi
    fi
  fi
''
