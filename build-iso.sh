CURRENT_DIR=$(pwd)
TEMPDIR="$CURRENT_DIR/KubuntuTemp"
ORIGINAL_ISO="/home/lemmyg/Downloads/kubuntu-24.10-desktop-amd64.iso"       # Path to the original ISO
DESTINATION="$TEMPDIR/output"
ISO_MOUNT_DIR="$TEMPDIR/kubuntu-original"    # Temporary mount point for the original ISO
ISO_WORK_DIR="$TEMPDIR/kubuntu-iso"          # Working directory for the new ISO
CHROOT_DIR="$TEMPDIR/kubuntu-edit"           # Chroot environment directory
NEW_ISO="$DESTINATION/custom-kubuntu.iso"        # Path for the new ISO
CODENAME="oracular"                       # Codename for T2 repository
mkdir -p "$CURRENT_DIR/KubuntuTemp"
cd $TEMPDIR
mount
T2_KERNEL=$(sudo chroot "$CHROOT_DIR" /bin/bash -c "apt-cache depends linux-t2 | grep -Eo 'linux-image-[^ ]+' | head -n 1")
echo $T2_KERNEL
KERNEL_VERSION=$(echo "$T2_KERNEL" | sed 's/linux-image-//')
# Update GRUB Configuration in ISO
sudo cp "$CHROOT_DIR/boot/vmlinuz-$KERNEL_VERSION" "$ISO_WORK_DIR/casper/vmlinuz"
sudo cp "$CHROOT_DIR/boot/initrd.img-$KERNEL_VERSION" "$ISO_WORK_DIR/casper/initrd"
cat <<EOL | sudo tee "$ISO_WORK_DIR/boot/grub/grub.cfg"
menuentry "Kubuntu 24.10 $KERNEL_VERSION" {
    set gfxpayload=keep
    linux /casper/vmlinuz-$KERNEL_VERSION boot=casper quiet splash intel_iommu=on iommu=pt pcie_ports=compat ---
    initrd /casper/initrd.img-$KERNEL_VERSION
}
EOL

sudo mksquashfs "$CHROOT_DIR" "$ISO_WORK_DIR/casper/filesystem.squashfs" -comp xz -processors 12 -noappend
sudo grub-mkrescue -o "$NEW_ISO" "$ISO_WORK_DIR"
