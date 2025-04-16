# User configuration for all hosts
{ pkgs, ... }:

{
  # Create a default non-root user with sudo privileges
  users.users.admin = {
    isNormalUser = true;
    home = "/home/admin";
    description = "System Administrator";
    extraGroups = [
      "wheel"      # Admin/sudo privileges
      "networkmanager"
      "disk"
      "audio"
      "video"
      "storage"
      "input"
      "docker"     # Docker access (if using docker)
    ];
    shell = pkgs.bash;
    openssh.authorizedKeys.keys = [
      "ssh-rsa AAAAB3NzaC1yc2EAAA... replace-with-your-actual-key"
      # Add additional keys as needed
    ];
    # Add a password hash if needed for local console access
    # Use `mkpasswd -m sha-512` to generate
    # hashedPassword = "";
  };

  # Optionally create another user for specific purposes
  users.users.service = {
    isNormalUser = true;
    home = "/home/service";
    description = "Service Account";
    extraGroups = [ "docker" ];
    shell = pkgs.bash;
    openssh.authorizedKeys.keys = [
      "ssh-rsa AAAAB3NzaC1yc2EAAA... replace-with-your-actual-key"
    ];
  };

  # User management settings
  users = {
    mutableUsers = false;  # Disable the ability to change passwords using passwd
    defaultUserShell = pkgs.bash;
  };

  # Allow sudo for wheel group without password
  security.sudo = {
    enable = true;
    wheelNeedsPassword = false;
    # Add custom sudo rules if needed
    extraRules = [
      {
        groups = [ "wheel" ];
        commands = [
          { command = "ALL"; options = [ "NOPASSWD" ]; }
        ];
      }
    ];
  };

  # Enable Docker for service accounts if needed
  virtualisation.docker.enable = true;

  # Shell configuration for all users
  programs = {
    bash = {
      enableCompletion = true;
      # Common bash configuration
      interactiveShellInit = ''
        # Customize prompt
        export PS1='\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '
        # Set common aliases
        alias ll='ls -la'
        alias la='ls -A'
        alias l='ls -CF'
      '';
    };
  };
}
