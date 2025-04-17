# Base system configuration for all hosts
{ pkgs, lib, ... }:

{
  # System-wide environment settings
  environment = {
    # Default system packages
    systemPackages = with pkgs; [
      # Core utilities
      coreutils
      curl
      wget
      git
      vim
      nano
      htop
      file
      tree
      zip
      unzip
      rsync

      # System tools
      usbutils
      pciutils
      lshw
      lsof
      psmisc

      # Monitoring
      iotop
      iftop

      # Network utilities
      inetutils
      dnsutils
      nmap
      nettools
      tcpdump
      whois
    ];

    # Default variables for all shells
    variables = {
      EDITOR = "vim";
    };
  };

  # Enable nix flakes
  nix = {
    package = pkgs.nixVersions.stable;
    settings = {
      # Optimize store automatically
      auto-optimise-store = true;
      # Allow remote builds
      trusted-users = [ "root" "admin" ];
    };
    # Regular garbage collection
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 7d";
    };
  };

  # Configure console settings
  console = {
    font = "Lat2-Terminus16";
    keyMap = "us";
  };

  # Set default locale and timezone
  i18n.defaultLocale = "en_US.UTF-8";
  time.timeZone = "UTC"; # Change to your timezone if needed

  # Enable common services
  services = {
    # Enable cron service
    cron.enable = true;

    # Enable log watching
    logind.lidSwitch = "ignore"; # Don't suspend when closing laptop lid

    # Disable unneeded services
    xserver.enable = false;
    printing.enable = false;

    # Enable fstrim for SSDs
    fstrim.enable = true;
  };

  # Security settings
  security = {
    # Sudo configuration
    sudo = {
      enable = true;
      wheelNeedsPassword = false; # Allow sudoers to use sudo without password
    };

    # PAM settings
    pam = {
      loginLimits = [
        { domain = "@wheel"; type = "soft"; item = "nofile"; value = "524288"; }
        { domain = "@wheel"; type = "hard"; item = "nofile"; value = "1048576"; }
      ];
    };
  };

  # System-wide shell aliases
  programs.bash = {
    enableCompletion = true;
    shellAliases = {
      ll = "ls -la";
      update = "sudo nixos-rebuild switch";
    };
  };

  # This value determines the NixOS release with which your system is compatible
  system.stateVersion = "24.05"; # DO NOT CHANGE this value unless you know what you're doing!
}
