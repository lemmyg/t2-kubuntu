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
      

# Run entrypoint.sh to extract and customize the ISO
echo "Starting extraction and customization..."
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
exit
# Run create_iso.sh to generate the new ISO
# echo "Creating the custom ISO..."
#/bin/bash -c "
#    ROOT_PATH=${ROOT_PATH} \\
#    IMAGE_PATH=${IMAGE_PATH} \\
#    CHROOT_PATH=${CHROOT_PATH}_${ALTERNATIVE} \\
#    KERNEL_VERSION=${KERNEL_VERSION}-${ALTERNATIVE} \\
#    ALTERNATIVE=${ALTERNATIVE} \\
#    ${ROOT_PATH}/02_create_iso.sh

#echo "Custom ISO creation process complete. Find the ISO at /path/to/output/custom.iso"
