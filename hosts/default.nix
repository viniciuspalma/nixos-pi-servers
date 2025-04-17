# Default host module that routes to specific host configurations
{
  config,
  lib,
  ...
}: {
  imports = [
    ./common
  ];
}
