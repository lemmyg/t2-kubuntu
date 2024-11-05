set -eu -o pipefail
# Prepare the ISO Directories
mkdir -p "$ISO_MOUNT_DIR" "$ISO_WORK_DIR" "$CHROOT_DIR"
# Mount the Original ISO and Copy Files
apt update && apt install -y util-linux rsync squashfs-tools
echo "mounting $ISO_IMAGE"
losetup -fP $ISO_IMAGE;
sleep 3
mount -o loop "$ISO_IMAGE" "$ISO_MOUNT_DIR"
rsync -a "$ISO_MOUNT_DIR/" "$ISO_WORK_DIR"
umount "$ISO_MOUNT_DIR"
unsquashfs -d "$CHROOT_DIR" "$ISO_WORK_DIR/casper/filesystem.squashfs"



