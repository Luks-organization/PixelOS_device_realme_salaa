/*
 * SPDX-FileCopyrightText: The LineageOS Project
 * SPDX-License-Identifier: Apache-2.0
 */

#include <vector>
#include <cstdlib>
#include <fstream>
#include <cstring>

#include <android-base/file.h>
#include <android-base/logging.h>
#include <android-base/properties.h>
#include <android-base/strings.h>

#define _REALLY_INCLUDE_SYS__SYSTEM_PROPERTIES_H_
#include <sys/_system_properties.h>
#include <sys/sysinfo.h>
#include <sys/stat.h>
#include <sys/types.h>

#include "vendor_init.h"
#include "property_service.h"

#include <fs_mgr_dm_linear.h>

using android::base::ReadFileToString;

namespace {

const char* const OPERATOR_CODE_FILE = "/proc/oplusVersion/operatorName";

// Helper function to override or add system properties
void property_override(char const prop[], char const value[], bool add = true) {
    prop_info* pi = (prop_info*) __system_property_find(prop);
    if (pi) {
        __system_property_update(pi, value, strlen(value));
    } else if (add) {
        __system_property_add(prop, strlen(prop), value, strlen(value));
    }
}

// Helper function to set "ro.build.prop" related properties
void set_ro_build_prop(const std::string& prop, const std::string& value, bool product = true) {
    const std::vector<std::string> prop_types = {
        "", "bootimage.", "odm.", "odm_dlkm.", "product.",
        "system.", "system_ext.", "vendor.", "vendor_dlkm."
    };

    for (const auto& source : prop_types) {
        std::string prop_name;
        if (product) {
            prop_name = "ro.product." + source + prop;
        } else {
            prop_name = "ro." + source + "build." + prop;
        }
        property_override(prop_name.c_str(), value.c_str(), false);
    }
}

// Function to set Dalvik VM properties based on total RAM size
void load_dalvik_properties(void) {
    struct sysinfo sys;
    if (sysinfo(&sys) != 0) {
        return; // Exit if sysinfo() fails
    }

    struct DalvikHeapConfig {
        const char* heapstartsize;
        const char* heapgrowthlimit;
        const char* heapsize;
        const char* heaptargetutilization;
        const char* heapminfree;
        const char* heapmaxfree;
    };

    static const DalvikHeapConfig heap_configs[] = {
        { "24m", "384m", "512m", "0.46", "8m", "48m" }, // >= 7GB RAM
        { "16m", "256m", "512m", "0.5",  "8m", "32m" }, // >= 5GB RAM
        { "8m",  "192m", "512m", "0.6",  "8m", "16m" }  // >= 3GB RAM
    };

    const DalvikHeapConfig* config = nullptr;

    if (sys.totalram >= 7ull * 1024 * 1024 * 1024) {
        config = &heap_configs[0];
    } else if (sys.totalram >= 5ull * 1024 * 1024 * 1024) {
        config = &heap_configs[1];
    } else if (sys.totalram >= 3ull * 1024 * 1024 * 1024) {
        config = &heap_configs[2];
    } else {
        return; // Exit if RAM is less than 3GB
    }

    // Apply heap properties
    property_override("dalvik.vm.heapstartsize", config->heapstartsize);
    property_override("dalvik.vm.heapgrowthlimit", config->heapgrowthlimit);
    property_override("dalvik.vm.heapsize", config->heapsize);
    property_override("dalvik.vm.heaptargetutilization", config->heaptargetutilization);
    property_override("dalvik.vm.heapminfree", config->heapminfree);
    property_override("dalvik.vm.heapmaxfree", config->heapmaxfree);
}

// Function to set device-specific properties based on operator code
void set_device_props(void) {
    std::string operator_code_raw, model, device, marketname, fingerprint;

    if (ReadFileToString(OPERATOR_CODE_FILE, &operator_code_raw)) {
        int operator_code = std::stoi(operator_code_raw);
        
        // Mapping operator codes to device properties
        switch (operator_code) {
            case 140: case 141: case 146: case 149:
                model = "RMX2151"; device = "RMX2151L1"; marketname = "realme 7"; fingerprint = "realme/RMX2151/RMX2151L1:12/SP1A.210812.016/Q.bf75e7-1:user/release-keys"; break;
            case 142:
                model = "RMX2153"; device = "RMX2153L1"; marketname = "realme 7"; fingerprint = "realme/RMX2156/RMX2156L1:12/SP1A.210812.016/Q.11e8c10-4e353:user/release-keys"; break;
            case 94: case 148:
                model = "RMX2155"; device = "RMX2155L1"; marketname = "realme 7"; fingerprint = "realme/RMX2155/RMX2155L1:12/SP1A.210812.016/Q.GDPR.bf75e7-1:user/release-keys"; break;
            case 90: case 92:
                model = "RMX2156"; device = "RMX2156L1"; marketname = "realme Narzo 30 4G"; fingerprint = "realme/RMX2156/RMX2156L1:12/SP1A.210812.016/Q.174ebd4_fa4d:user/release-keys"; break;
            case 143:
                model = "RMX2161"; device = "RMX2161L1"; marketname = "realme Narzo 20 Pro"; fingerprint = "realme/RMX2156/RMX2156L1:12/SP1A.210812.016/Q.11e8c10-4e353:user/release-keys"; break;
            case 145: case 147:
                model = "RMX2163"; device = "RMX2163L1"; marketname = "realme Narzo 20 Pro"; fingerprint = "realme/RMX2163T2/RMX2163L1:12/SP1A.210812.016/Q.bf75e7-1:user/release-keys"; break;
            default:
                LOG(ERROR) << "Unknown operator found: " << operator_code;
                return; // Early exit on unknown operator
        }
    }

    // Set build properties
    set_ro_build_prop("model", model);
    set_ro_build_prop("device", device);
    set_ro_build_prop("name", model);
    set_ro_build_prop("product", model, false);
    set_ro_build_prop("marketname", marketname);
    set_ro_build_prop("fingerprint", fingerprint);

    // Additional properties
    property_override("ro.product.name", model.c_str());
    property_override("ro.product.device", device.c_str());
    property_override("ro.vendor.device", device.c_str());
    property_override("ro.product.marketname", marketname.c_str());
    property_override("bluetooth.device.default_name", marketname.c_str());
    property_override("vendor.usb.product_string", marketname.c_str());
    property_override("ro.product.build.fingerprint", fingerprint.c_str());
    property_override("ro.build.fingerprint", fingerprint.c_str());
    property_override("ro.system.build.fingerprint", fingerprint.c_str());
    property_override("ro.vendor.build.fingerprint", fingerprint.c_str());
    property_override("ro.odm.build.fingerprint", fingerprint.c_str());
    property_override("ro.system_ext.build.fingerprint", fingerprint.c_str());
}

} // anonymous namespace

void vendor_load_properties(void) {
#ifndef __ANDROID_RECOVERY__
    set_device_props();
#endif
    load_dalvik_properties();
}

