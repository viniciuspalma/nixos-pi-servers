#!/usr/bin/env bash

# Script to test disko disk configurations for each host
# Usage: ./test-disko.sh [hostname]
# If no hostname is provided, tests all hosts

set -euo pipefail

HOSTS=("dev-365" "dev-901" "dev-142" "dev-605")
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print status messages
print_status() {
  local msg="$1"
  local color="${2:-$BLUE}"
  echo -e "${color}${msg}${NC}"
}

# Function to test disko configuration for a single host
test_disko() {
  local host="$1"
  print_status "Testing disko configuration for ${host}..." "$BLUE"

  # Extract disko config and show it
  print_status "  Extracting disko configuration..." "$YELLOW"

  # Build the disko script for the host
  if nix build ".#nixosConfigurations.${host}.config.system.build.diskoScript" --no-link; then
    print_status "  ✅ Disko configuration for ${host} builds successfully" "$GREEN"

    # Get the build path
    disko_script=$(nix path-info ".#nixosConfigurations.${host}.config.system.build.diskoScript")

    # Show the script content (head only to avoid flooding the console)
    print_status "  Preview of disko script (first 10 lines):" "$YELLOW"
    head -n 10 "$disko_script"
    print_status "  (truncated...)" "$YELLOW"

    # Check for common disk layout issues
    if grep -q "Failed to create partition" "$disko_script"; then
      print_status "  ❌ Partition creation issues detected" "$RED"
      return 1
    fi

    # Count partitions to ensure we have at least some
    partition_count=$(grep -c "Create partition" "$disko_script" || true)
    if [[ $partition_count -eq 0 ]]; then
      print_status "  ❌ No partitions detected in disko script" "$RED"
      return 1
    else
      print_status "  ✅ Found $partition_count partitions" "$GREEN"
    fi

    return 0
  else
    print_status "  ❌ Disko configuration for ${host} failed to build" "$RED"
    return 1
  fi
}

# Main function
main() {
  local single_host="$1"
  local failed=0

  print_status "===== STARTING DISKO TESTS =====" "$BLUE"

  if [[ -n "${single_host}" ]]; then
    # Test a single host
    if test_disko "${single_host}"; then
      print_status "✅ Host ${single_host} disko test passed" "$GREEN"
    else
      print_status "❌ Host ${single_host} disko test failed" "$RED"
      failed=1
    fi
  else
    # Test all hosts
    for host in "${HOSTS[@]}"; do
      if test_disko "${host}"; then
        print_status "✅ Host ${host} disko test passed" "$GREEN"
      else
        print_status "❌ Host ${host} disko test failed" "$RED"
        failed=1
      fi
      echo ""
    done
  fi

  if [[ ${failed} -eq 0 ]]; then
    print_status "===== ALL DISKO TESTS PASSED =====" "$GREEN"
    return 0
  else
    print_status "===== SOME DISKO TESTS FAILED =====" "$RED"
    return 1
  fi
}

# If the script is called with an argument, test only that host
if [[ $# -gt 0 ]]; then
  main "$1"
else
  main ""
fi
