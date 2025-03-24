#
# SPDX-FileCopyrightText: The LineageOS Project
# SPDX-License-Identifier: Apache-2.0
#

# Cloning required repositories for making rum:

# Kernel Source:
git clone https://github.com/Luks-organization/kernel_realme_mt6785 kernel/realme/mt6785

# Vendor Source:
git clone https://github.com/Luks-organization/vendor_realme_salaa vendor/realme/salaa
unzip vendor/realme/salaa/radio/md1img.zip -d vendor/realme/salaa/radio && rm vendor/realme/salaa/radio/md1img.zip
unzip vendor/realme/salaa/proprietary/odm/lib64/libstfaceunlockppl.zip -d vendor/realme/salaa/proprietary/odm/lib64 && rm vendor/realme/salaa/proprietary/odm/lib64/libstfaceunlockppl.zip

# Hardware of Mediatek and Oplus:
git clone https://github.com/LineageOS/android_hardware_oplus -b lineage-22.2 hardware/oplus
git clone https://github.com/LineageOS/android_hardware_mediatek hardware/mediatek

# SEPolicy:
git clone https://github.com/RisingTechOSS-devices/device_mediatek_sepolicy_vndr device/mediatek/sepolicy_vndr

# Clang
git clone --depth=1 https://gitlab.com/RismaPwd/clang toolchain/clang-proton

# DspVolumeSynchronizer
git clone https://github.com/Luks-organization/DspVolumeSynchronizer packages/apps/DspVolumeSynchronizer

# OplusDolby
git clone https://github.com/Luks-organization/DolbyManager packages/apps/OplusDolby

# RealmeParts
git clone https://github.com/Luks-organization/RealmeParts packages/apps/RealmeParts

# Dt2w
git clone https://github.com/Luks-organization/Dt2w packages/apps/Dt2w

# RevampedFMRadio && FMRadio
git clone https://github.com/Luks-organization/RevampedFMRadio packages/apps/RevampedFMRadio
git clone https://github.com/LineageOS/android_packages_apps_FMRadio packages/apps/FMRadio

# ViperFX
git clone https://github.com/Luks-organization/ViperFX vendor/ViperFX

# CameraGo
#git clone https://github.com/Luks-organization/CameraGo vendor/CameraGo

# CameraGo
#unzip vendor/CameraGo/CameraGo/CameraGo.zip -d vendor/CameraGo/CameraGo && rm vendor/CameraGo/CameraGo/CameraGo.zip

# Make the build faster using ccache
export USE_CCACHE=1
export CCACHE_DIR=~/.ccache
ccache -M 40G
ccache -o compression=true

# Disable and stop systemd-oomd service.
systemctl disable --now systemd-oomd && sudo apt-get purge systemd-oomd -y
