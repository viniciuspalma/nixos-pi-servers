#!/usr/bin/env bash
# Script to check disk configurations on target machines

set -e

# Check if hostname and SSH target are provided
if [ $# -lt 2 ]; then
  echo "Usage: $0 <hostname> <ssh-target>"
  echo "Example: $0 dev-365 vini@192.168.13.104"
  exit 1
fi

HOSTNAME=$1
SSH_TARGET=$2

echo "=== Checking disk configuration for $HOSTNAME ($SSH_TARGET) ==="

echo "1. Block devices list:"
ssh "$SSH_TARGET" "lsblk -o NAME,SIZE,MOUNTPOINTS,FSTYPE,MODEL,SERIAL"

echo -e "\n2. Disk information (without sudo):"
ssh "$SSH_TARGET" "ls -l /dev/disk/by-id/ | grep -v 'part[0-9]'"
ssh "$SSH_TARGET" "lsblk -d -o NAME,SIZE,MODEL,SERIAL,TRAN"

echo -e "\n3. Current mount points:"
ssh "$SSH_TARGET" "df -h"

echo -e "\n4. FSTAB configuration:"
ssh "$SSH_TARGET" "cat /etc/fstab"

echo -e "\n5. Boot information:"
ssh "$SSH_TARGET" "ls -la /boot/efi 2>/dev/null || echo 'No EFI directory found'"
ssh "$SSH_TARGET" "[ -d /sys/firmware/efi ] && echo 'System booted in UEFI mode' || echo 'System booted in BIOS mode'"

echo -e "\n=== Check complete for $HOSTNAME ==="
echo "Based on this information, update the disk configuration in:"
echo "    hosts/$HOSTNAME/default.nix"
echo "You should identify the main disk device (e.g., /dev/sda, /dev/vda, /dev/nvme0n1)"
