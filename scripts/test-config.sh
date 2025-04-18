#!/usr/bin/env bash

# Script to test NixOS configurations for each host
# Usage: ./test-config.sh [hostname]
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

# Function to validate a single host configuration
validate_host() {
  local host="$1"
  print_status "Testing configuration for ${host}..." "$BLUE"

  # Step 1: Check if the NixOS configuration builds
  print_status "  Building NixOS configuration..." "$YELLOW"
  if nix build ".#nixosConfigurations.${host}.config.system.build.toplevel" --no-link --show-trace; then
    print_status "  ✅ NixOS configuration for ${host} builds successfully" "$GREEN"
  else
    print_status "  ❌ NixOS configuration for ${host} failed to build" "$RED"
    return 1
  fi

  # Step 2: Validate disko configuration
  print_status "  Validating disko configuration..." "$YELLOW"
  if nix build ".#nixosConfigurations.${host}.config.system.build.diskoScript" --no-link; then
    print_status "  ✅ Disko configuration for ${host} builds successfully" "$GREEN"

    # Get the build path
    disko_script=$(nix path-info ".#nixosConfigurations.${host}.config.system.build.diskoScript")

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
  else
    print_status "  ❌ Disko configuration for ${host} failed to build" "$RED"
    return 1
  fi

  # Step 3: Validate Kubernetes configuration
  print_status "  Validating Kubernetes configuration..." "$YELLOW"
  if grep -q "kubernetes" "${REPO_ROOT}/hosts/${host}/default.nix"; then
    print_status "  ✅ Host ${host} has Kubernetes configuration" "$GREEN"
  else
    print_status "  ❌ Host ${host} is missing Kubernetes configuration" "$RED"
    return 1
  fi

  # All tests passed
  print_status "✅ All tests passed for ${host}" "$GREEN"
  return 0
}

# Main function
main() {
  local single_host="$1"
  local failed=0

  print_status "===== STARTING CONFIGURATION TESTS =====" "$BLUE"

  if [[ -n "${single_host}" ]]; then
    # Test a single host
    if validate_host "${single_host}"; then
      print_status "✅ Host ${single_host} passed all tests" "$GREEN"
    else
      print_status "❌ Host ${single_host} failed some tests" "$RED"
      failed=1
    fi
  else
    # Test all hosts
    for host in "${HOSTS[@]}"; do
      if validate_host "${host}"; then
        print_status "✅ Host ${host} passed all tests" "$GREEN"
      else
        print_status "❌ Host ${host} failed some tests" "$RED"
        failed=1
      fi
      echo ""
    done
  fi

  if [[ ${failed} -eq 0 ]]; then
    print_status "===== ALL TESTS PASSED =====" "$GREEN"
    return 0
  else
    print_status "===== SOME TESTS FAILED =====" "$RED"
    return 1
  fi
}

# If the script is called with an argument, test only that host
if [[ $# -gt 0 ]]; then
  main "$1"
else
  main ""
fi
