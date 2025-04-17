{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.raspberry-pi;
  rpi-boot-builder = pkgs.writeShellApplication {
    name = "rpi-boot-builder.sh";
    runtimeInputs = with pkgs; [
      coreutils
      findutils
    ];
    text = ''
      shopt -s nullglob

      FW_FILES=(
        ${pkgs.raspberrypifw}/share/raspberrypi/boot/overlays
        ${pkgs.raspberrypifw}/share/raspberrypi/boot/*.dtb
        ${pkgs.raspberrypifw}/share/raspberrypi/boot/bootcode.bin
        ${pkgs.raspberrypifw}/share/raspberrypi/boot/fixup*.dat
        ${pkgs.raspberrypifw}/share/raspberrypi/boot/start*.elf
      )
      DEST_DIR=/boot

      find "$DEST_DIR" -mindepth 1 -delete
      cp -r -t "$DEST_DIR" "''${FW_FILES[@]}"

      cp -t "$DEST_DIR" "$1"/{kernel,initrd}
      echo "$(cat "$1/kernel-params") init=$1/init" > "$DEST_DIR/cmdline.txt"
      cat << EOF > "$DEST_DIR/config.txt"
      $(cat ${./config.txt})
      kernel=kernel
      initramfs initrd followkernel
      EOF
    '';
  };
in {
  options.raspberry-pi = {
    loader = {
      enable = mkOption {
        default = false;
        type = types.bool;
      };
    };
  };

  config = mkIf cfg.loader.enable {
    system.boot.loader.id = "rpi";
    system.build.installBootLoader = "${rpi-boot-builder}/bin/rpi-boot-builder.sh";
  };
}
