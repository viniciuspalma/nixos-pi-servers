#!/usr/bin/env bash
# Script to setup and check all hosts

set -e

# Host IP mapping - Update these with your actual IP addresses
declare -A HOST_IPS=(
  ["dev-605"]="192.168.13.101"
  ["dev-901"]="192.168.13.102"
  ["dev-142"]="192.168.13.103"
  ["dev-365"]="192.168.13.104"
)

# SSH user - Update with your actual SSH user
SSH_USER="vini"

# Check if a specific host is specified
if [ $# -eq 1 ]; then
  HOSTS=("$1")
  if [ -z "${HOST_IPS[$1]}" ]; then
    echo "Error: Unknown host: $1"
    echo "Available hosts: ${!HOST_IPS[@]}"
    exit 1
  fi
else
  # Process all hosts
  HOSTS=("${!HOST_IPS[@]}")
fi

# Function to check disks on a host
check_disks() {
  local host=$1
  local ip=${HOST_IPS[$host]}
  local ssh_target="${SSH_USER}@${ip}"

  echo "===== Checking disks on $host ($ssh_target) ====="
  ./scripts/check-disks.sh "$host" "$ssh_target"
  echo ""
}

# Process each host
for host in "${HOSTS[@]}"; do
  check_disks "$host"
done

echo "===== Next steps ====="
echo "1. Review the disk information for each host"
echo "2. Update the disk configurations using:"
echo "   ./scripts/update-disk-config.sh <hostname> <disk-device>"
echo "   Example: ./scripts/update-disk-config.sh dev-365 /dev/vda"
echo ""
echo "Available hosts:"
for host in "${!HOST_IPS[@]}"; do
  echo "  - $host (${HOST_IPS[$host]})"
done
