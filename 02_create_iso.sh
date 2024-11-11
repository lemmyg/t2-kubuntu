#!/bin/bash
set -eu -o pipefail
echo >&2 "===]> Info: Getting Kernel version ... "
echo $T2_KERNEL
KERNEL_VERSION=$(echo "$T2_KERNEL" | sed 's/linux-image-//')
# Update GRUB Configuration in ISO
echo >&2 "===]> Info: Copying Linux vmlinuz and initrd ... "
cp "$CHROOT_DIR/boot/vmlinuz-$KERNEL_VERSION" "$ISO_WORK_DIR/casper/vmlinuz"
cp "$CHROOT_DIR/boot/initrd.img-$KERNEL_VERSION" "$ISO_WORK_DIR/casper/initrd"

echo >&2 "===]> Info: Modify existing grub.cfg ..."
sed -i 's/--- quiet splash/boot=casper text intel_iommu=on iommu=pt pcie_ports=compat ---/g' "$ISO_WORK_DIR/boot/grub/grub.cfg"

echo >&2 "===]> Info: Generating final ISO ... "
(cd "$ISO_WORK_DIR" && find . -type f -print0 | xargs -0 md5sum > md5sum.txt)
mkdir -p ${DESTINATION}
#grub-mkrescue -o "${DESTINATION}/kubuntu-24.10-t2-desktop-amd64.iso" "$ISO_WORK_DIR"
xorriso -as mkisofs \
  -iso-level 3 \
  -full-iso9660-filenames \
  -volid "KUBUNTU-T2" \
  -eltorito-boot boot/grub/i386-pc/eltorito.img \
  -no-emul-boot \
  -boot-load-size 4 \
  -boot-info-table \
  -eltorito-alt-boot \
  -e EFI/boot/bootx64.efi \
  -no-emul-boot \
  -isohybrid-gpt-basdat \
  -output "${DESTINATION}/kubuntu-24.10-t2-desktop-amd64.iso" \
  "$ISO_WORK_DIR"




echo "Custom ISO creation process complete. Find the ISO at ${DESTINATION}/kubuntu-24.10-t2-desktop-amd64.iso"


