#!/usr/bin/env bash

# Check if the correct number of arguments is provided
if [ "$#" -ne 3 ]; then
    echo "Error: Provide 3 arguments"
    echo "Usage: $0 vendor codename architecture"
    exit 1
fi

# Create Lindroid and TheMuppets manifests
#rm -rf .repo/local_manifests
#repo init -u https://github.com/LineageOS-UL/android.git -b lineage-21.0 --git-lfs
#mkdir -p .repo/local_manifests/
#wget https://raw.githubusercontent.com/MHS195/Lindroid-files/refs/heads/main/manifests/general/lindroid.xml -O .repo/local_manifests/lindroid.xml
#repo sync -c
git clone https://github.com/Linux-on-droid/vendor_lindroid -b lindroid-21 vendor/lindroid
git clone https://github.com/Linux-on-droid/vendor_extra -b lindroid-21 vendor/extra
git clone https://github.com/Linux-on-droid/libhybris -b lindroid-21 libhybris
git clone https://github.com/Linux-on-droid/external_lxc -b lindroid-21 external/lxc
git clone https://github.com/MHS195/device_htc_oce1 -b lindroid device/htc/oce
git clone https://github.com/MHS195/vendor_htc_oce -b lineage-21.0 vendor/htc
git clone https://github.com/MHS195/android_kernel_htc_oce -b LXC kernel/htc/oce
#Pull device specific data
source build/envsetup.sh
#breakfast $2

# Patches
## Download patches
wget https://raw.githubusercontent.com/Soupborsh/Lindroid-files/refs/heads/main/patches/general/EventHub.patch
wget https://raw.githubusercontent.com/Soupborsh/Lindroid-files/refs/heads/main/patches/general/0001-Ignore-uevent-s-with-null-name-for-Extcon-WiredAcces.patch
wget https://github.com/Linux-on-droid/vendor_lindroid/commit/10f98759162a0034a2afa62c5977f9bcf921db13.patch

## Apply patches
patch frameworks/native/services/inputflinger/reader/EventHub.cpp EventHub.patch
git apply 0001-Ignore-uevent-s-with-null-name-for-Extcon-WiredAcces.patch --directory=frameworks/base/
patch -R vendor/lindroid/app/app/src/main/java/org/lindroid/ui/DisplayActivity.java 10f98759162a0034a2afa62c5977f9bcf921db13.patch

## Remove patch files
rm EventHub.patch
rm 0001-Ignore-uevent-s-with-null-name-for-Extcon-WiredAcces.patch
rm 10f98759162a0034a2afa62c5977f9bcf921db13.patch

# Fix building by removing CONFIG_SYSVIPC from android-base.config
#KERNEL_VERSION=$(grep -E '^VERSION' kernel/$1/$2/Makefile | cut -d' ' -f3)
#PATCHLEVEL=$(grep -E '^PATCHLEVEL' kernel/$1/$2/Makefile | cut -d' ' -f3)

#sed -i '/# CONFIG_SYSVIPC is not set/d' kernel/configs/*/android-${KERNEL_VERSION}.${PATCHLEVEL}/android-base.config

# Build
croot
brunch $2

exit 0
