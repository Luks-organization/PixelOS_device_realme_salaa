#!/bin/bash
#
# SPDX-FileCopyrightText: PixelOS
#
# SPDX-License-Identifier: Apache-2.0
#

set -e

DEVICE=salaa
VENDOR=realme

# Load extract_utils and do some sanity checks
MY_DIR="${BASH_SOURCE%/*}"
if [[ ! -d "${MY_DIR}" ]]; then MY_DIR="${PWD}"; fi

ANDROID_ROOT="${MY_DIR}/../../.."

export PATCHELF_VERSION=0_17_2

HELPER="${ANDROID_ROOT}/tools/extract-utils/extract_utils.sh"
if [ ! -f "${HELPER}" ]; then
    echo "Unable to find helper script at ${HELPER}"
    exit 1
fi
source "${HELPER}"

# Default to sanitizing the vendor folder before extraction
CLEAN_VENDOR=true

ONLY_FIRMWARE=
KANG=
SECTION=

while [ "${#}" -gt 0 ]; do
    case "${1}" in
        -n | --no-cleanup )
                CLEAN_VENDOR=false
                ;;
        -k | --kang )
                KANG="--kang"
                ;;
        -s | --section )
                SECTION="${2}"; shift
                CLEAN_VENDOR=false
                ;;
        * )
                SRC="${1}"
                ;;
    esac
    shift
done

if [ -z "${SRC}" ]; then
    SRC="adb"
fi

function blob_fixup {
    case "$1" in
        vendor/bin/hw/android.hardware.media.c2@1.2-mediatek-64b)
            [ "$2" = "" ] && return 0
            "${PATCHELF}" --replace-needed "libavservices_minijail_vendor.so" "libavservices_minijail.so" "${2}"
            grep -q "libstagefright_foundation-v33.so" "${2}" || "${PATCHELF}" --add-needed "libstagefright_foundation-v33.so" "${2}"
            ;;
        vendor/lib64/hw/android.hardware.camera.provider@2.6-impl-mediatek.so)
            [ "$2" = "" ] && return 0
            grep -q "libcamera_metadata_shim.so" "${2}" || "${PATCHELF}" --add-needed "libcamera_metadata_shim.so" "${2}"
            "${PATCHELF}" --replace-needed "libutils.so" "libutils-v32.so" "${2}"
            ;;
        vendor/lib64/libmtkcam_featurepolicy.so)
            [ "$2" = "" ] && return 0
            # evaluateCaptureConfiguration()
            sed -i "s/\x34\xE8\x87\x40\xB9/\x34\x28\x02\x80\x52/" "$2"
            ;;
        vendor/lib*/hw/vendor.mediatek.hardware.pq@2.13-impl.so|vendor/lib*/libmtkcam_stdutils.so)
            [ "$2" = "" ] && return 0
            "${PATCHELF}" --replace-needed "libutils.so" "libutils-v32.so" "${2}"
            ;;
        vendor/etc/vintf/manifest/manifest_media_c2_V1_2_default.xml)
            [ "$2" = "" ] && return 0
            sed -i 's/1.1/1.2/' "$2"
            ;;
        vendor/bin/hw/android.hardware.wifi@1.0-service-lazy)
            [ "$2" = "" ] && return 0
            "${PATCHELF}" --replace-needed "libwifi-hal.so" "libwifi-hal-mtk.so" "${2}"
            ;;
        vendor/lib*/libkeystore-engine-wifi-hidl.so)
            [ "$2" = "" ] && return 0
            "$PATCHELF" --replace-needed android.system.keystore2-V1-ndk_platform.so android.system.keystore2-V1-ndk.so "$2"
            ;;
        system_ext/lib64/libsource.so | system_ext/bin/vtservice)
            [ "$2" = "" ] && return 0
            grep -q libui_shim.so "$2" || "${PATCHELF}" --add-needed libui_shim.so "${2}"
            ;;
        system_ext/lib64/libsink.so | system_ext/bin/vtservice)
            [ "$2" = "" ] && return 0
            grep -q libshim_sink.so "$2" || "${PATCHELF}" --add-needed libshim_sink.so "${2}"
            ;;
        lib*/libem_support_jni.so)
            [ "$2" = "" ] && return 0
            grep -q libjni_shim.so "$2" || "${PATCHELF}" --add-needed libjni_shim.so "${2}"
            ;;
        vendor/lib64/hw/sensors.mt6785.so)
            [ "$2" = "" ] && return 0
            grep -q "libsensors_shim.so" "$2" || "${PATCHELF}" --add-needed "libsensors_shim.so" "${2}"
            ;;
        vendor/etc/init/android.hardware.media.c2@1.2-mediatek.rc)
            [ "$2" = "" ] && return 0
            sed -i 's/@1.2-mediatek/@1.2-mediatek-64b/g' "${2}"
            ;;
        vendor/etc/init/android.hardware.bluetooth@1.1-service-mediatek.rc)
            [ "$2" = "" ] && return 0
            sed -i '/vts/Q' "$2"
            ;;
        vendor/bin/hw/android.hardware.gnss-service.mediatek|vendor/lib64/hw/android.hardware.gnss-impl-mediatek.so)
            [ "$2" = "" ] && return 0
            "${PATCHELF}" --replace-needed "android.hardware.gnss-V1-ndk_platform.so" "android.hardware.gnss-V1-ndk.so" "${2}"
            ;;
        vendor/lib64/libmnl.so)
            [ "$2" = "" ] && return 0
            grep -q "libcutils.so" "${2}" || "${PATCHELF}" --add-needed "libcutils.so" "${2}"
            ;;
        vendor/bin/mnld|vendor/lib*/libcam.utils.sensorprovider.so|vendor/lib*/libaalservice.so|vendor/lib64/hw/android.hardware.sensors@2.X-subhal-mediatek.so)
            [ "$2" = "" ] && return 0
            grep -q "android.hardware.sensors@1.0-convert-shared.so" "${2}" || "${PATCHELF}" --add-needed "android.hardware.sensors@1.0-convert-shared.so" "${2}"
            ;;
        vendor/lib64/libSQLiteModule_VER_ALL.so|vendor/lib64/lib3a.flash.so)
            [ "$2" = "" ] && return 0
            grep -q "liblog.so" "${2}" || "${PATCHELF_0_17_2}" --add-needed "liblog.so" "${2}"
            ;;
        vendor/bin/mtk_agpsd)
            [ "$2" = "" ] && return 0
           grep -q "libcrypto-v33.so" "${2}" || "$PATCHELF" --replace-needed "libcrypto.so" "libcrypto-v33.so" "${2}"
           grep -q "libssl-v33.so" "${2}" || "$PATCHELF" --replace-needed "libssl.so" "libssl-v33.so" "${2}"
            ;;
        vendor/lib/hw/audio.primary.mt6785.so)
            [ "$2" = "" ] && return 0 
           "${PATCHELF}" --replace-needed "libalsautils.so" "libalsautils-v31.so" "${2}"
            ;;
        vendor/lib*/libnvram.so|vendor/lib*/libsysenv.so|vendor/bin/hw/android.hardware.neuralnetworks@1.3-service-mtk-neuron|odm/bin/hw/vendor.oplus.hardware.charger@1.0-service)
            [ "$2" = "" ] && return 0 
            grep -q "libbase_shim.so" "${2}" || "${PATCHELF}" --add-needed "libbase_shim.so" "${2}"
            ;;
        vendor/lib64/libadsprpc.so|vendor/lib64/libcdsprpc.so)
            [ "$2" = "" ] && return 0 
            grep -q "libc++.so" "${2}" || "${PATCHELF}" --replace-needed "libstdc++.so" "libc++.so" "${2}"
            ;;
        odm/lib/soundfx/awinic.haptic.effect.so|vendor/lib/libthha.so)
            [ "$2" = "" ] && return 0 
           "${PATCHELF}" --clear-symbol-version __aeabi_memcpy "${2}"
           "${PATCHELF}" --clear-symbol-version __aeabi_memset "${2}"
           "${PATCHELF}" --clear-symbol-version __gnu_Unwind_Find_exidx "${2}"
            ;;
        odm/lib64/hw/fpsensor_fingerprint.default.so|odm/lib64/hw/sidefp_fingerprint.default.so)
            [ "$2" = "" ] && return 0 
            grep -q "libMcClient.so" "${2}" || "${PATCHELF}" --replace-needed "libTeeClient.so" "libMcClient.so" "${2}"
            ;;
        *)
            return 1
            ;;
    esac
}
function blob_fixup_dry() {
    blob_fixup "$1" ""
}

# Initialize the helper
setup_vendor "${DEVICE}" "${VENDOR}" "${ANDROID_ROOT}" false "${CLEAN_VENDOR}"

if [ -z "${ONLY_FIRMWARE}" ]; then
    extract "${MY_DIR}/proprietary-files.txt" "${SRC}" "${KANG}" --section "${SECTION}"
fi

if [ -z "${SECTION}" ]; then
    extract_firmware "${MY_DIR}/proprietary-firmware.txt" "${SRC}"
fi

"${MY_DIR}/setup-makefiles.sh"
