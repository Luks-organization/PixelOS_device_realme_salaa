#
# SPDX-FileCopyrightText: PixelOS
#
# SPDX-License-Identifier: Apache-2.0
#

DEVICE_PATH                                     := device/realme/salaa

# APEX
DEXPREOPT_GENERATE_APEX_IMAGE                   := true

# Architecture
TARGET_ARCH                                     := arm64
TARGET_ARCH_VARIANT                             := armv8-2a-dotprod
TARGET_CPU_ABI                                  := arm64-v8a
TARGET_CPU_ABI2 :=
TARGET_CPU_VARIANT                              := cortex-a76

TARGET_2ND_ARCH                                 := arm
TARGET_2ND_ARCH_VARIANT                         := armv8-2a
TARGET_2ND_CPU_ABI                              := armeabi-v7a
TARGET_2ND_CPU_ABI2                             := armeabi
TARGET_2ND_CPU_VARIANT                          := cortex-a55

# Assert
TARGET_OTA_ASSERT_DEVICE                        := RMX2151L1,RMX2153L1,RMX2155L1,RMX2156L1,RMX2161L1,RMX2163L1,salaa

# Bootloader
TARGET_BOOTLOADER_BOARD_NAME                    := RM6785
TARGET_NO_BOOTLOADER                            := true

# Mediatek support
BOARD_HAS_MTK_HARDWARE                          := true
BOARD_HAVE_MTK_FM                               := true
BOARD_TEE_VARIANT                               ?= trustonic

# Audio 
USE_CUSTOM_AUDIO_POLICY                         := 1
BOARD_USES_ALSA_AUDIO                           := true
TARGET_EXCLUDES_AUDIOFX                         := true
AUDIO_FEATURE_ENABLED_DS2_DOLBY_DAP             := true

# Display
TARGET_SCREEN_DENSITY                           := 480

# HWUI
HWUI_COMPILE_FOR_PERF                           := true
USE_OPENGL_RENDERER                             := true

# Global LTO
KERNEL_FULL_LLVM                                := true
GLOBAL_THINLTO                                  := true
USE_THINLTO_CACHE                               := true
SKIP_ABI_CHECKS                                 := true

# Metadata
BOARD_USES_METADATA_PARTITION                   := true
BOARD_ROOT_EXTRA_FOLDERS                        += metadata

# Init
TARGET_INIT_VENDOR_LIB                          := //$(DEVICE_PATH):libinit_salaa
TARGET_RECOVERY_DEVICE_MODULES                  := libinit_salaa

# Properties
TARGET_SYSTEM_PROP                              += $(DEVICE_PATH)/configs/props/system.prop
TARGET_VENDOR_PROP                              += $(DEVICE_PATH)/configs/props/vendor.prop
TARGET_PRODUCT_PROP                             += $(DEVICE_PATH)/configs/props/product.prop

# Lineage Health
TARGET_HEALTH_CHARGING_CONTROL_CHARGING_PATH    := /sys/class/oplus_chg/battery/mmi_charging_enable

# Releasetools
TARGET_RELEASETOOLS_EXTENSIONS                  := $(DEVICE_PATH)

# RIL
ENABLE_VENDOR_RIL_SERVICE                       := true

# SPL
VENDOR_SECURITY_PATCH                           := 2024-04-05

# VNDK
BOARD_VNDK_VERSION                              := current

# MediaTek IMS
TARGET_PROVIDES_MEDIATEK_IMS_STACK              := true

# MTK Rules
TARGET_PROVIDES_MTK_PROPRIETARY                 := true

# Recovery
TARGET_RECOVERY_PIXEL_FORMAT                    := RGBX_8888
TARGET_RECOVERY_FSTAB                           := $(DEVICE_PATH)/rootdir/etc/fstab.mt6785
TARGET_USERIMAGES_USE_EXT4                      := true
TARGET_USERIMAGES_USE_F2FS                      := true
TARGET_USES_MKE2FS                              := true

# Partitions
BOARD_FLASH_BLOCK_SIZE                          := 131072
BOARD_BOOTIMAGE_PARTITION_SIZE                  := 33554432
BOARD_RECOVERYIMAGE_PARTITION_SIZE              := 102760448
BOARD_CACHEIMAGE_PARTITION_SIZE                 := 452984832
BOARD_DTBOIMG_PARTITION_SIZE                    := 8388608
BOARD_CACHEIMAGE_FILE_SYSTEM_TYPE               := ext4

# Partitions (Dynamic)
BOARD_SUPER_PARTITION_SIZE                      := 8053063680
BOARD_SUPER_PARTITION_GROUPS                    := main
BOARD_MAIN_SIZE                                 := 8048869376
BOARD_MAIN_PARTITION_LIST                       := system system_ext vendor product odm

# File system
TARGE_USE_EROFS                                 := true
ifeq ($(TARGE_USE_EROFS), true)
BOARD_SYSTEMIMAGE_FILE_SYSTEM_TYPE              := erofs
BOARD_SYSTEM_EXTIMAGE_FILE_SYSTEM_TYPE          := erofs
BOARD_VENDORIMAGE_FILE_SYSTEM_TYPE              := erofs
BOARD_ODMIMAGE_FILE_SYSTEM_TYPE                 := erofs
BOARD_PRODUCTIMAGE_FILE_SYSTEM_TYPE             := erofs
BOARD_EROFS_PCLUSTER_SIZE                       := 262144
BOARD_EROFS_COMPRESSOR                          := lz4
else
BOARD_PRODUCTIMAGE_FILE_SYSTEM_TYPE             := ext4
BOARD_SYSTEM_EXTIMAGE_FILE_SYSTEM_TYPE          := ext4
BOARD_VENDORIMAGE_FILE_SYSTEM_TYPE              := ext4
BOARD_ODMIMAGE_FILE_SYSTEM_TYPE                 := ext4
endif

TARGET_COPY_OUT_ODM                             := odm
TARGET_COPY_OUT_VENDOR                          := vendor
TARGET_COPY_OUT_PRODUCT                         := product
TARGET_COPY_OUT_SYSTEM_EXT                      := system_ext
TARGET_VENDOR_MODULES                           := $(TARGET_OUT_VENDOR)/lib/modules

# Boot Image
BOARD_KERNEL_IMAGE_NAME                         := Image.gz
BOARD_BOOTIMG_HEADER_VERSION                    := 2
BOARD_KERNEL_BASE                               := 0x40078000
BOARD_KERNEL_OFFSET                             := 0x00008000
BOARD_KERNEL_PAGESIZE                           := 2048
BOARD_KERNEL_TAGS_OFFSET                        := 0x0bc08000
BOARD_RAMDISK_OFFSET                            := 0x07c08000
BOARD_KERNEL_SECOND_OFFSET                      := 0x00e88000
BOARD_DTB_OFFSET                                := 0x0bc08000

BOARD_INCLUDE_RECOVERY_DTBO                     := true
BOARD_KERNEL_SEPARATED_DTBO                     := true
BOARD_INCLUDE_DTB_IN_BOOTIMG                    := true
BOARD_RAMDISK_USE_LZ4                           := true

BOARD_KERNEL_CMDLINE                            := bootopt=64S3,32N2,64N2
BOARD_KERNEL_CMDLINE                            += androidboot.init_fatal_reboot_target=recovery
BOARD_KERNEL_CMDLINE                            += kpti=off

BOARD_MKBOOTIMG_ARGS                            := --ramdisk_offset $(BOARD_RAMDISK_OFFSET)
BOARD_MKBOOTIMG_ARGS                            += --second_offset $(BOARD_KERNEL_SECOND_OFFSET)
BOARD_MKBOOTIMG_ARGS                            += --tags_offset $(BOARD_KERNEL_TAGS_OFFSET)
BOARD_MKBOOTIMG_ARGS                            += --dtb_offset $(BOARD_DTB_OFFSET)
BOARD_MKBOOTIMG_ARGS                            += --header_version $(BOARD_BOOTIMG_HEADER_VERSION)
BOARD_MKBOOTIMG_ARGS                            += --board ""

# Kernel Compiling
TARGET_KERNEL_VERSION                           := 4.14
TARGET_KERNEL_ARCH                              := arm64
TARGET_KERNEL_HEADER_ARCH                       := arm64
TARGET_KERNEL_SOURCE                            := kernel/realme/mt6785
TARGET_KERNEL_CONFIG                            := salaa_defconfig
TARGET_KERNEL_CLANG_COMPILE                     := true
TARGET_KERNEL_CLANG_VERSION                     := proton
TARGET_KERNEL_CLANG_PATH                        := $(shell pwd)/toolchain/clang-$(TARGET_KERNEL_CLANG_VERSION)
TARGET_KERNEL_ADDITIONAL_FLAGS                  := LLVM=1 LLVM_IAS=1 AS=llvm-as AR=llvm-ar NM=llvm-nm OBJCOPY=llvm-objcopy OBJDUMP=llvm-objdump STRIP=llvm-strip
KERNEL_CC                                       := CC=clang
KERNEL_LD                                       := LD=ld.lld

# ART
ART_BUILD_TARGET_NDEBUG                         := true
ART_BUILD_TARGET_DEBUG                          := false
ART_BUILD_HOST_NDEBUG                           := true
ART_BUILD_HOST_DEBUG                            := false

# Verified Boot
BOARD_AVB_ENABLE                                := true
BOARD_AVB_ALGORITHM                             := SHA256_RSA2048
BOARD_AVB_KEY_PATH                              := external/avb/test/data/testkey_rsa2048.pem
BOARD_AVB_MAKE_VBMETA_IMAGE_ARGS                += --flags 3

BOARD_AVB_RECOVERY_KEY_PATH                     := external/avb/test/data/testkey_rsa4096.pem
BOARD_AVB_RECOVERY_ALGORITHM                    := SHA256_RSA4096
BOARD_AVB_RECOVERY_ROLLBACK_INDEX               := 1
BOARD_AVB_RECOVERY_ROLLBACK_INDEX_LOCATION      := 1

BOARD_AVB_VBMETA_SYSTEM                         := product system system_ext
BOARD_AVB_VBMETA_SYSTEM_KEY_PATH                := external/avb/test/data/testkey_rsa2048.pem
BOARD_AVB_VBMETA_SYSTEM_ALGORITHM               := SHA256_RSA2048
BOARD_AVB_VBMETA_SYSTEM_ROLLBACK_INDEX          := 1
BOARD_AVB_VBMETA_SYSTEM_ROLLBACK_INDEX_LOCATION := 2

BOARD_AVB_VBMETA_VENDOR                         := odm vendor
BOARD_AVB_VBMETA_VENDOR_KEY_PATH                := external/avb/test/data/testkey_rsa2048.pem
BOARD_AVB_VBMETA_VENDOR_ALGORITHM               := SHA256_RSA2048
BOARD_AVB_VBMETA_VENDOR_ROLLBACK_INDEX          := 1
BOARD_AVB_VBMETA_VENDOR_ROLLBACK_INDEX_LOCATION := 3

# Use sha256 hashtree
BOARD_AVB_SYSTEM_ADD_HASHTREE_FOOTER_ARGS       += --hash_algorithm sha256
BOARD_AVB_SYSTEM_EXT_ADD_HASHTREE_FOOTER_ARGS   += --hash_algorithm sha256
BOARD_AVB_PRODUCT_ADD_HASHTREE_FOOTER_ARGS      += --hash_algorithm sha256
BOARD_AVB_VENDOR_ADD_HASHTREE_FOOTER_ARGS       += --hash_algorithm sha256
BOARD_AVB_ODM_ADD_HASHTREE_FOOTER_ARGS          += --hash_algorithm sha256

# Wi-Fi
WPA_SUPPLICANT_VERSION                          := VER_0_8_X
BOARD_WPA_SUPPLICANT_DRIVER                     := NL80211
BOARD_HOSTAPD_DRIVER                            := NL80211
WIFI_DRIVER_FW_PATH_PARAM                       := "/dev/wmtWifi"
WIFI_DRIVER_FW_PATH_STA                         := "STA"
WIFI_DRIVER_FW_PATH_AP                          := "AP"
WIFI_DRIVER_FW_PATH_P2P                         := "P2P"
WIFI_DRIVER_STATE_CTRL_PARAM                    := "/dev/wmtWifi"
WIFI_DRIVER_STATE_ON                            := "1"
WIFI_DRIVER_STATE_OFF                           := "0"
WIFI_HAL_INTERFACE_COMBINATIONS                 := {{{STA}, 2}}
WIFI_HAL_INTERFACE_COMBINATIONS                 += ,{{{AP}, 2},}
WIFI_HAL_INTERFACE_COMBINATIONS                 += ,{{{STA}, 1}, {{AP}, 1}}
WIFI_HAL_INTERFACE_COMBINATIONS                 += ,{{{STA}, 1}, {{P2P}, 1}}
WIFI_HAL_INTERFACE_COMBINATIONS                 += ,{{{STA}, 1}, {{NAN}, 1}}
WIFI_HIDL_UNIFIED_SUPPLICANT_SERVICE_RC_ENTRY   := true

# Compatibility matrix
DEVICE_MATRIX_FILE                              := $(DEVICE_PATH)/configs/vintf/compatibility_matrix.xml
DEVICE_MANIFEST_FILE                            := $(DEVICE_PATH)/configs/vintf/manifest.xml
DEVICE_MANIFEST_SKUS                            += nfc
DEVICE_MANIFEST_NFC_FILES                       := $(DEVICE_PATH)/configs/vintf/manifest_nfc.xml

# HIDL
DEVICE_FRAMEWORK_COMPATIBILITY_MATRIX_FILE      += \
    hardware/mediatek/vintf/mediatek_framework_compatibility_matrix.xml \
    vendor/aosp/config/device_framework_matrix.xml \
    $(DEVICE_PATH)/configs/vintf/device_framework_matrix.xml

# SELinux
include device/mediatek/sepolicy_vndr/SEPolicy.mk
include $(DEVICE_PATH)/sepolicy/SEPolicy.mk
SELINUX_IGNORE_NEVERALLOWS := true  # TODO: DROP THIS

# Kernel Modules
#KERNEL_PATH := kernel/realme/mt6785
#BOARD_KERNEL_MODULE_DIR := $(KERNEL_PATH)vendor/lib/modules
#BOARD_VENDOR_KERNEL_MODULES += $(wildcard $(dir $(BOARD_KERNEL_MODULE_DIR))/*.ko)
#BOARD_VENDOR_KERNEL_MODULES_LOAD := $(strip $(shell cat $(BOARD_KERNEL_MODULE_DIR)/modules.load))

# Vibrator
$(call soong_config_set,mediatek_vibrator,supports_effects,true)

# Inherit the proprietary files
include vendor/realme/salaa/BoardConfigVendor.mk
