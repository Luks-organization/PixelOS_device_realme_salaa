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

HELPER="${ANDROID_ROOT}/tools/extract-utils/extract_utils.sh"
if [ ! -f "${HELPER}" ]; then
    echo "Unable to find helper script at ${HELPER}"
    exit 1
fi
source "${HELPER}"

function vendor_imports() {
    cat <<EOF >>"$1"
		"device/realme/salaa",
		"hardware/mediatek",
		"hardware/mediatek/libmtkperf_client",
		"hardware/oplus",
EOF
}

function lib_to_package_fixup_odm_variants() {
    if [ "$2" != "odm" ]; then
        return 1
    fi

    case "$1" in
            vendor.oplus.hardware.biometrics.fingerprint@2.1)
            echo "$1_odm"
            ;;
            *)
            return 1
            ;;
    esac
}

function lib_to_package_fixup_vendor_variants() {
    if [ "$2" != "vendor" ]; then
        return 1
    fi

    case "$1" in
        vendor.oplus.hardware.commondcs@1.0 | \
        libremosaiclib | \
        libremosaic_wrapper | \
        libhwm-oplus | \
	vendor.mediatek.hardware.videotelephony@1.0)
            echo "$1_vendor"
            ;;
            *)
            return 1
            ;;
    esac
}

function lib_to_package_fixup() {
    lib_to_package_fixup_odm_variants "$@" ||
    lib_to_package_fixup_vendor_variants "$@" ||
        lib_to_package_fixup_clang_rt_ubsan_standalone "$1" ||
        lib_to_package_fixup_proto_3_9_1 "$1"
}

# Initialize the helper
setup_vendor "${DEVICE}" "${VENDOR}" "${ANDROID_ROOT}"

# Warning headers and guards
write_headers

write_makefiles "${MY_DIR}/proprietary-files.txt"

append_firmware_calls_to_makefiles "${MY_DIR}/proprietary-firmware.txt"

# Finish
write_footers
