#!/usr/bin/env bash
# Script to deploy NixOS to a remote machine using nixos-anywhere

set -e

# Check if hostname and SSH target are provided
if [ $# -lt 2 ]; then
  echo "Usage: $0 <hostname> <ssh-target> [--password]"
  echo "Example: $0 dev-365 vini@192.168.13.104"
  echo ""
  echo "Options:"
  echo "  --password  Use password authentication instead of keys"
  exit 1
fi

HOSTNAME=$1
SSH_TARGET=$2
USE_PASSWORD=0

if [[ "$3" == "--password" ]]; then
  USE_PASSWORD=1
fi

# Enter the nix shell for deployment tools
if ! command -v nixos-anywhere &>/dev/null; then
  echo "nixos-anywhere not found. Entering nix shell..."
  SCRIPT_DIR=$(dirname "$0")
  cd "$SCRIPT_DIR/.."
  exec nix-shell --run "scripts/deploy.sh $HOSTNAME $SSH_TARGET ${3:-}"
  exit 0
fi

echo "===== Deploying NixOS to $HOSTNAME ($SSH_TARGET) ====="

# Sanity check: make sure the host configuration exists
HOST_CONFIG="hosts/$HOSTNAME/default.nix"
if [ ! -f "$HOST_CONFIG" ]; then
  echo "Error: Host configuration not found: $HOST_CONFIG"
  exit 1
fi

echo "Building NixOS configuration..."

# Perform a build to ensure everything is valid
CONFIG_RESULT=$(nix-build -E "(builtins.getFlake \"$PWD\").nixosConfigurations.\"$HOSTNAME\".config.system.build.toplevel" --no-out-link)

if [ $? -ne 0 ]; then
  echo "Error: Failed to build NixOS configuration for $HOSTNAME"
  exit 1
fi

echo "Building disko script..."
DISKO_SCRIPT=$(nix-build -E "(builtins.getFlake \"$PWD\").nixosConfigurations.\"$HOSTNAME\".config.system.build.diskoScript" --no-out-link)

if [ $? -ne 0 ]; then
  echo "Error: Failed to build disko script for $HOSTNAME"
  exit 1
fi

echo "Ready to deploy NixOS to $SSH_TARGET with hostname $HOSTNAME"
echo "This will ERASE ALL DATA on the target machine's disk."
echo "Configuration: $CONFIG_RESULT"
echo "Disk script: $DISKO_SCRIPT"
read -p "Are you sure you want to continue? (y/N) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
  echo "Deployment cancelled."
  exit 1
fi

# Deployment command
NIXOS_ANYWHERE_CMD="nixos-anywhere --store-paths \"$DISKO_SCRIPT\" \"$CONFIG_RESULT\""

if [ $USE_PASSWORD -eq 1 ]; then
  echo "Using password authentication"
  # Ask for password
  read -sp "Enter SSH password for $SSH_TARGET: " SSH_PASS
  echo

  # Export the password and add env-password flag
  export SSH_PASS
  NIXOS_ANYWHERE_CMD="$NIXOS_ANYWHERE_CMD --env-password"
fi

# Final command with target
NIXOS_ANYWHERE_CMD="$NIXOS_ANYWHERE_CMD $SSH_TARGET"

echo "Running deployment..."
echo "$NIXOS_ANYWHERE_CMD"
eval "$NIXOS_ANYWHERE_CMD"

if [ $? -eq 0 ]; then
  echo "===== Deployment completed successfully ====="
  echo "Your new NixOS system is now installed on $HOSTNAME"
  echo "You can SSH into it using: ssh root@<ip-address>"
else
  echo "===== Deployment failed ====="
  echo "Check the error messages above for details"
fi
