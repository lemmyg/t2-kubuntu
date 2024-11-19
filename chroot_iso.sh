#!/bin/bash
set -eu -o pipefail


echo >&2 "===]> Info: Configure environment... "
echo >&2 "===]> Info: Configure and update apt... "

apt update
apt install -y curl
# Add T2 Repository and Install Packages
CODENAME=$(lsb_release -cs)
curl -s --compressed "https://adityagarg8.github.io/t2-ubuntu-repo/KEY.gpg" | gpg --dearmor | tee /etc/apt/trusted.gpg.d/t2-ubuntu-repo.gpg >/dev/null
curl -s --compressed -o /etc/apt/sources.list.d/t2.list "https://adityagarg8.github.io/t2-ubuntu-repo/t2.list"
echo "deb [signed-by=/etc/apt/trusted.gpg.d/t2-ubuntu-repo.gpg] https://github.com/AdityaGarg8/t2-ubuntu-repo/releases/download/${CODENAME} ./" | tee -a /etc/apt/sources.list.d/t2.list
#apt update
apt update
# Add Kernel Parameters to GRUB for Installed System
sed -i 's/GRUB_CMDLINE_LINUX_DEFAULT="quiet splash"/GRUB_CMDLINE_LINUX_DEFAULT="quiet splash intel_iommu=on iommu=pt pcie_ports=compat"/' /etc/default/grub
update-grub
apt install -y linux-t2 apple-t2-audio-config apple-firmware-script

KERNEL_VERSION=$(dpkg -l | grep -E "^ii  linux-image-[0-9]+\.[0-9]+\.[0-9\.\-]+-generic" | awk '{print $2}' | sed 's/linux-image-\(.*\)-generic/\1/')
#apt purge -y -qq \
#    linux-generic \
#    linux-headers-${KERNEL_VERSION} \
#    linux-headers-${KERNEL_VERSION}-generic \
#    linux-headers-generic \
#    linux-image-${KERNEL_VERSION}-generic \
#    linux-image-generic \
#    linux-modules-${KERNEL_VERSION}-generic \
#    linux-modules-extra-${KERNEL_VERSION}-generic

# Add udev Rule for AMD GPU Power Management
cat <<EOL > /etc/udev/rules.d/30-amdgpu-pm.rules
KERNEL=="card[012]", SUBSYSTEM=="drm", DRIVERS=="amdgpu", ATTR{device/power_dpm_force_performance_level}="low"
EOL

# Add Required Modules to initramfs for Apple Keyboard
cat <<EOL >> /etc/initramfs-tools/modules
# Required modules for getting the built-in apple keyboard to work:
snd
snd_pcm
apple-bce
EOL
update-initramfs -u

# Blacklist Modules for T2 Chip Internal Ethernet
cat <<EOL >> /etc/modprobe.d/blacklist.conf
# Disable for now T2 chip internal USB ethernet
blacklist cdc_ncm
blacklist cdc_mbim
EOL



# Clean up
#apt-get autoremove -y
apt clean
rm -rf /var/cache/apt/archives/*
rm -rf /tmp/* ~/.bash_history
rm -rf /tmp/setup_files




