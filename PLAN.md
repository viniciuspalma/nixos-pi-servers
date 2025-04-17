# NixOS Provisioning Plan for Multiple Machines

## Overview

This plan outlines the steps to provision four NixOS machines with a modular configuration approach, leveraging nixos-anywhere for remote deployment. The machines will have the following hostnames:

- dev-365
- dev-901
- dev-142
- dev-605

## Project Structure

```
nixos-pi-servers/
├── flake.nix
├── hosts/
│   ├── common/
│   │   ├── default.nix
│   │   ├── users.nix
│   │   └── ssh.nix
│   ├── dev-365/
│   │   └── default.nix
│   ├── dev-901/
│   │   └── default.nix
│   ├── dev-142/
│   │   └── default.nix
│   ├── dev-605/
│   │   └── default.nix
│   └── default.nix
├── modules/
│   ├── disk-layouts/
│   │   ├── default.nix
│   │   └── standard-layout.nix
│   └── services/
│       ├── default.nix
│       └── ... (service-specific modules)
├── shell.nix
└── scripts/
    ├── deploy.sh
    └── test-config.sh
```

## Steps

### ✅ 1. Initialize Project and Dependencies

1. ✅ Set up the project directory
2. ✅ Initialize dependencies with `npins` for:
   - ✅ nixpkgs
   - ✅ disko
   - ✅ nixos-anywhere
3. ✅ Create a `shell.nix` file for development environment

### ✅ 2. Create Modular Configuration Framework

1. ✅ Configure the flake.nix to:

   - ✅ Define inputs (nixpkgs, disko, nixos-anywhere)
   - ✅ Set up NixOS configurations for each hostname
   - ✅ Organize shared and machine-specific outputs

2. ✅ Create the hosts module structure:

   - ✅ `hosts/common/` for shared configurations
   - ✅ Individual host directories with specific configurations

3. ✅ Implement the disk layout modules:
   - ✅ Standard disk layout applicable to all machines
   - ✅ Any machine-specific disk layout variations if needed

### ✅ 3. Configure Common Modules

1. ✅ SSH configuration with appropriate keys
2. ✅ Network configuration
3. ✅ Base system configuration
4. ✅ User management

### ✅ 4. Configure Host-Specific Modules

For each host (dev-365, dev-901, dev-142, dev-605):

1. ✅ Define hostname
2. ✅ Set specific hardware configuration if needed
3. ✅ Configure host-specific services
4. ✅ Set appropriate disk device paths

### ✅ 5. Test Configurations

1. ✅ Create a script to validate configurations:
   - ✅ scripts/test-config.sh for general configuration testing
   - ✅ scripts/test-disko.sh for disk layout testing
2. ✅ Test disk layouts using the disko test functionality:
   ```
   nix-build -E "((import <nixpkgs> {}).nixos [ ./configuration.nix ]).installTest"
   ```

### 6. Deployment Setup

1. Create a deployment script that:

   - Accepts hostname as parameter
   - Builds the appropriate configuration
   - Uses nixos-anywhere to deploy to the target machine
   - Example:
     ```sh
     ./scripts/deploy.sh dev-365 root@192.168.1.101
     ```

2. The script should:
   - Build the configuration
   - Build the disko script
   - Deploy using nixos-anywhere

### 7. System Update Process

1. Document the update process:
   - Updating npins dependencies
   - Rebuilding and deploying updated configurations
   - Using nixos-rebuild for regular updates after initial deployment

## Implementation Notes

- Use conditional imports based on hostname for modular configurations
- Store machine-specific information (like IP addresses) in a structured way
- Ensure SSH keys are properly configured for unattended installation
- Consider using a CI/CD pipeline for testing configurations before deployment

## Prerequisites for Target Machines

- Each machine must be running Linux with kexec support
- SSH access must be configured
- Proper network configuration for remote access
- Knowledge of disk device identifiers for each machine
