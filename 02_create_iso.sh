#!/bin/bash
set -eu -o pipefail
echo >&2 "===]> Info: Getting Kernel version ... "
echo $T2_KERNEL
KERNEL_VERSION=$(echo "$T2_KERNEL" | sed 's/linux-image-//')
# Update GRUB Configuration in ISO
echo >&2 "===]> Info: Updating ISO Grub ... "
cp "$CHROOT_DIR/boot/vmlinuz-$KERNEL_VERSION" "$ISO_WORK_DIR/casper/vmlinuz"
cp "$CHROOT_DIR/boot/initrd.img-$KERNEL_VERSION" "$ISO_WORK_DIR/casper/initrd"
cat <<EOL | tee "$ISO_WORK_DIR/boot/grub/grub.cfg"
menuentry "Kubuntu 24.10 $KERNEL_VERSION" {
    set gfxpayload=keep
    linux /casper/vmlinuz boot=casper quiet splash intel_iommu=on iommu=pt pcie_ports=compat ---
    initrd /casper/initrd
}
EOL
echo >&2 "===]> Info: Squashing Kubuntu file system ... "
mksquashfs "$CHROOT_DIR" "$ISO_WORK_DIR/casper/filesystem.squashfs" -comp xz -noappend
echo >&2 "===]> Info: Generating final ISO ... "
mkdir -p ${DESTINATION}
grub-mkrescue -o "${DESTINATION}/kubuntu-24.10-t2-desktop-amd64.iso" "$ISO_WORK_DIR"
echo "Custom ISO creation process complete. Find the ISO at ${DESTINATION}/kubuntu-24.10-t2-desktop-amd64.iso"

