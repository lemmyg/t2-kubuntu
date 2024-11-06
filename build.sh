#!/bin/bash
set -eu -o pipefail
ROOT_PATH=$(pwd)
TEMPDIR="/root/work"
DESTINATION="$ROOT_PATH/output"
ISO_MOUNT_DIR="$TEMPDIR/kubuntu-original"    # Temporary mount point for the original ISO
ISO_WORK_DIR="$TEMPDIR/kubuntu-iso"          # Working directory for the new ISO
CHROOT_DIR="$TEMPDIR/kubuntu-edit"           # Chroot environment directory
NEW_ISO="$DESTINATION/custom-kubuntu.iso"        # Path for the new ISO
CODENAME="oracular"
echo "ROOT_PATH=$ROOT_PATH"
echo "TEMPDIR=$TEMPDIR"  
echo "DESTINATION=$DESTINATION"  
echo "ISO_MOUNT_DIR=$ISO_MOUNT_DIR"  
echo "ISO_WORK_DIR=$ISO_WORK_DIR"  
echo "CHROOT_DIR=$CHROOT_DIR"
echo "NEW_ISO=$NEW_ISO"
echo "CODENAME=$CODENAME" 
echo >&2 "===]> Info: Installings required packages..."     
apt update && apt update && \
    DEBIAN_FRONTEND=noninteractive TZ=Europe/London apt install -y tzdata \
	&& apt install -y util-linux rsync squashfs-tools grub-pc-bin grub-common xorriso
# Run entrypoint.sh to extract and customize the ISO
echo >&2 "===]> Info: Starting extraction and customization..."
/bin/bash -c "
    ISO_IMAGE=${ISO_IMAGE} \\
    DESTINATION=${DESTINATION} \\
    ISO_MOUNT_DIR=${ISO_MOUNT_DIR} \\
    ISO_WORK_DIR=${ISO_WORK_DIR} \\
    CHROOT_DIR=${CHROOT_DIR} \\
    NEW_ISO=${NEW_ISO} \\
    CODENAME=${CODENAME} \\
    ROOT_PATH=${ROOT_PATH} \\
    ${ROOT_PATH}/01_edit_iso.sh"

# Enter the Chroot Environment and Apply Customizations
echo >&2 "===]> Info: Creating chroot environment... "
# Mount Required Filesystems for Chroot
mount --bind /dev "${CHROOT_DIR}/dev"
mount --bind /dev/pts "${CHROOT_DIR}/dev/pts"
mount --bind /proc "${CHROOT_DIR}/proc"
mount --bind /sys "${CHROOT_DIR}/sys"




mkdir -p "${CHROOT_DIR}/tmp/setup_files"
rm -f "${CHROOT_DIR}/etc/resolv.conf"
cp /etc/resolv.conf "${CHROOT_DIR}/etc/resolv.conf"
cp "${ROOT_PATH}/chroot_iso.sh" "${CHROOT_DIR}/tmp/setup_files"
ls "${CHROOT_DIR}/tmp/setup_files"
echo >&2 "===]> Info: Running chroot environment... "
chroot "${CHROOT_DIR}" /bin/bash -c "/tmp/setup_files/chroot_iso.sh"
echo >&2 "===]> Info: Getting Kernel environment... "
T2_KERNEL=$(chroot "${CHROOT_DIR}" /bin/bash -c "apt-cache depends linux-t2 | grep -Eo 'linux-image-[^ ]+' | head -n 1")
echo >&2 "===]> Info: Cleanup the chroot environment... "
umount "${CHROOT_DIR}/dev/pts"
umount "${CHROOT_DIR}/dev"
umount "${CHROOT_DIR}/proc"
umount "${CHROOT_DIR}/sys"



echo >&2 "===]> Info: Creating iso ... "
# Run create_iso.sh to generate the new ISO
# echo "Creating the custom ISO..."
/bin/bash -c "
	ISO_IMAGE=${ISO_IMAGE} \\
    DESTINATION=${DESTINATION} \\
    ISO_MOUNT_DIR=${ISO_MOUNT_DIR} \\
    ISO_WORK_DIR=${ISO_WORK_DIR} \\
    CHROOT_DIR=${CHROOT_DIR} \\
    DESTINATION=${DESTINATION} \\
    CODENAME=${CODENAME} \\
    ROOT_PATH=${ROOT_PATH} \\
    T2_KERNEL=${T2_KERNEL} \\
	${ROOT_PATH}/02_create_iso.sh"


