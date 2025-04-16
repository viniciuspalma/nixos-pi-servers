# SSH configuration for all hosts
{ ... }:

{
  # Enable the OpenSSH daemon
  services.openssh = {
    enable = true;
    settings = {
      PermitRootLogin = "prohibit-password";
      PasswordAuthentication = false;
      X11Forwarding = false;
      KbdInteractiveAuthentication = false;
      PermitEmptyPasswords = false;

      # Hardening options
      LogLevel = "VERBOSE";
      MaxAuthTries = 3;
      MaxSessions = 10;
      TCPKeepAlive = true;

      # Cipher settings
      Ciphers = [
        "chacha20-poly1305@openssh.com"
        "aes256-gcm@openssh.com"
        "aes128-gcm@openssh.com"
        "aes256-ctr"
        "aes192-ctr"
        "aes128-ctr"
      ];
    };

    # Allow specific network interfaces if needed
    # listenAddresses = [
    #   { addr = "192.168.1.1"; port = 22; }
    # ];

    # Optionally enable host key checking and additional hardening
    extraConfig = ''
      AllowTcpForwarding no
      ClientAliveInterval 300
      ClientAliveCountMax 2
    '';
  };

  # Add your SSH public key here for root access during installation
  users.users.root.openssh.authorizedKeys.keys = [
    "ssh-rsa AAAAB3NzaC1yc2EAAA... replace-with-your-actual-key"
    # Add additional keys as needed
  ];
}
