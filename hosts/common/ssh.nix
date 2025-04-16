# SSH configuration for all hosts
{ ... }:

{
  # Enable the OpenSSH daemon
  services.openssh = {
    enable = true;
    settings = {
      PermitRootLogin = "prohibit-password";
      PasswordAuthentication = false;
    };
  };

  # Add your SSH public key here for root access during installation
  users.users.root.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICf3+Pnj8acqkAAJNK0WVQrJ/5rIomxxi4U6rCRpIK+v"
    # Add additional keys as needed
  ];
}
