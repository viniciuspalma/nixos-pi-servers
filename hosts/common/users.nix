# User configuration for all hosts
{ pkgs, ... }:

{
  # Create a default non-root user
  users.users.admin = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" ];
    shell = pkgs.bash;
    openssh.authorizedKeys.keys = [
      "ssh-rsa AAAAB3NzaC1yc2EAAA... replace-with-your-actual-key"
      # Add additional keys as needed
    ];
  };

  # Allow sudo for wheel group without password
  security.sudo = {
    enable = true;
    wheelNeedsPassword = false;
  };
}
