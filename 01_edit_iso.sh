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
#export HOME=/root
#export LC_ALL=C
# Enter the Chroot Environment and Apply Customizations
echo >&2 "===]> Info: Creating chroot environment... "
#mount --bind /dev "${CHROOT_DIR}/dev"
#mount --bind /run "${CHROOT_DIR}/run"
# Mount Required Filesystems for Chroot
#mount --bind /dev "${CHROOT_DIR}/dev"
mount --bind /dev "${CHROOT_DIR}/dev"
mount --bind /dev/pts "${CHROOT_DIR}/dev/pts"
mount --bind /proc "${CHROOT_DIR}/proc"
mount --bind /sys "${CHROOT_DIR}/sys"
#mount --bind /run "${CHROOT_DIR}/run"
mkdir -p "${CHROOT_DIR}/tmp/setup_files"
cp /etc/resolv.conf "${CHROOT_DIR}/etc/resolv.conf"
cp "${ROOT_PATH}/chroot_iso.sh" "${CHROOT_DIR}/tmp/setup_files"
ls "${CHROOT_DIR}/tmp/setup_files"
chroot "${CHROOT_DIR}" /bin/bash -c "CODENAME=${CODENAME} /tmp/setup_files/chroot_iso.sh"

echo >&2 "===]> Info: Cleanup the chroot environment... "
# In docker there is no run?
#umount "${CHROOT_DIR}/run"
#umount "${CHROOT_DIR}/dev"





umount "${CHROOT_DIR}/dev"
umount "${CHROOT_DIR}/dev/pts"
umount "${CHROOT_DIR}/proc"
umount "${CHROOT_DIR}/sys"
#umount "${CHROOT_DIR}/run"
