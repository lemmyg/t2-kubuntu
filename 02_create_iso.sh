#!/bin/bash
set -e

# Check if the chroot directory has contents
if [ ! -d "$CHROOT_DIR" ] || [ -z "$(ls -A "$CHROOT_DIR")" ]; then
  echo "Error: Chroot directory is empty or missing. Please run entrypoint.sh first."
  exit 1
fi

# Create the new ISO with updated content
xorriso -as mkisofs \
  -isohybrid-mbr /usr/lib/ISOLINUX/isohdpfx.bin \
  -c isolinux/boot.cat -b isolinux/isolinux.bin \
  -no-emul-boot -boot-load-size 4 -boot-info-table \
  -o "$NEW_ISO" "$CHROOT_DIR"

echo "Custom ISO created at $NEW_ISO"
