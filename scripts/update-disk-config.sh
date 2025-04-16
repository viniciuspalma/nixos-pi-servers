#!/usr/bin/env bash
# Script to update disk configuration for a host

set -e

# Check if hostname and disk device are provided
if [ $# -lt 2 ]; then
  echo "Usage: $0 <hostname> <disk-device>"
  echo "Example: $0 dev-365 /dev/sda"
  exit 1
fi

HOSTNAME=$1
DISK_DEVICE=$2

HOST_CONFIG="hosts/$HOSTNAME/default.nix"

if [ ! -f "$HOST_CONFIG" ]; then
  echo "Error: Host configuration not found: $HOST_CONFIG"
  exit 1
fi

echo "Updating disk configuration for $HOSTNAME to use $DISK_DEVICE..."

# Update the disk device in the configuration
sed -i.bak "s|disko.devices.disk.main.device = \".*\"|disko.devices.disk.main.device = \"$DISK_DEVICE\"|g" "$HOST_CONFIG"
sed -i.bak "s|boot.loader.grub.devices = \[ \".*\" \]|boot.loader.grub.devices = [ \"$DISK_DEVICE\" ]|g" "$HOST_CONFIG"

# Cleanup backup file
rm -f "${HOST_CONFIG}.bak"

echo "Configuration updated successfully."
echo "Check the updated configuration in: $HOST_CONFIG"
