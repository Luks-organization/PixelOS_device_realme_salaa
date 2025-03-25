#
# SPDX-FileCopyrightText: PixelOS
#
# SPDX-License-Identifier: Apache-2.0
#

# Inherit from those products. Most specific first.
$(call inherit-product, $(SRC_TARGET_DIR)/product/core_64_bit.mk)
$(call inherit-product, $(SRC_TARGET_DIR)/product/full_base_telephony.mk)
$(call inherit-product, $(SRC_TARGET_DIR)/product/non_ab_device.mk)

# Inherit from device makefile.
$(call inherit-product, $(LOCAL_PATH)/device.mk)

# Inherit some common Pixel OS stuff.
$(call inherit-product, vendor/aosp/config/common_full_phone.mk)

# ViperFX
$(call inherit-product-if-exists, vendor/ViperFX/ViperFX.mk)

# PixelOS flags
IS_OFFICIAL := false
TARGET_CALL_RECORDING_SUPPORTED := true
TARGET_SUPPORTS_QUICK_TAP := true
TARGET_FACE_UNLOCK_SUPPORTED := true
TARGET_DISABLE_EPPE := true
TARGET_DOES_NOT_SUPPORT_GOOGLE_BATTERY := true

# EvolutionX flags
WITH_GMS := true

# Device Information
PRODUCT_DEVICE := salaa
PRODUCT_NAME := aosp_$(PRODUCT_DEVICE)
PRODUCT_BRAND := realme
PRODUCT_MANUFACTURER := $(PRODUCT_BRAND)
PRODUCT_MODEL := realme 7/Narzo 20 Pro/Narzo 30 4G
PRODUCT_GMS_CLIENTID_BASE := android-$(PRODUCT_BRAND)

BUILD_FINGERPRINT := realme/RMX2156/RMX2156L1:12/SP1A.210812.016/Q.174ebd4_fa4d:user/release-keys
