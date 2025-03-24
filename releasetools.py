#
# SPDX-FileCopyrightText: PixelOS
#
# SPDX-License-Identifier: Apache-2.0
#

import common

def FullOTA_InstallBegin(info):
    # Read and write dynamic-remove-oppo file
    data = info.input_zip.read("RADIO/dynamic-remove-oppo")
    common.ZipWriteStr(info.output_zip, "dynamic-remove-oppo", data)
    info.script.AppendExtra('update_dynamic_partitions(package_extract_file("dynamic-remove-oppo"));')

def FullOTA_InstallEnd(info):
    # Call the generic OTA install end function for full OTA
    OTA_InstallEnd(info, incremental=False)

def IncrementalOTA_InstallEnd(info):
    # Call the generic OTA install end function for incremental OTA
    OTA_InstallEnd(info, incremental=True)

def AddImageOnly(info, basename, incremental, firmware):
    # Select appropriate zip based on whether the update is incremental
    input_zip = info.source_zip if incremental else info.input_zip
    # Read and write image or firmware data
    data_path = f"RADIO/{basename}" if firmware else f"IMAGES/{basename}"
    data = input_zip.read(data_path)
    common.ZipWriteStr(info.output_zip, basename, data)

def AddImage(info, basename, dest, incremental):
    # Add image only and then patch the destination unconditionally
    AddImageOnly(info, basename, incremental, firmware=False)
    info.script.Print(f"Patching {dest.split('/')[-1]} image unconditionally...")
    info.script.AppendExtra(f'package_extract_file("{basename}", "{dest}");')

def OTA_InstallEnd(info, incremental):
    # Print message indicating firmware images are being patched
    info.script.Print("Patching firmware images...")
    
    # List of firmware images and their respective destination paths
    firmware_images = [
        ("dtbo.img", "/dev/block/platform/bootdevice/by-name/dtbo"),
        ("vbmeta.img", "/dev/block/platform/bootdevice/by-name/vbmeta"),
        ("vbmeta_system.img", "/dev/block/platform/bootdevice/by-name/vbmeta_system"),
        ("vbmeta_vendor.img", "/dev/block/platform/bootdevice/by-name/vbmeta_vendor"),
    ]

    # Process each firmware image
    for basename, dest in firmware_images:
        AddImage(info, basename, dest, incremental)

    # Define mappings for binary and image files
    bin_map = {
        'logo': ['logo']
    }

    img_map = {
        'audio_dsp': ['audio_dsp'],
        'cam_vpu1': ['cam_vpu1'],
        'cam_vpu2': ['cam_vpu2'],
        'cam_vpu3': ['cam_vpu3'],
        'gz': ['gz1', 'gz2'],
        'lk': ['lk', 'lk2'],
        'md1img': ['md1img'],
        'scp': ['scp1', 'scp2'],
        'spmfw': ['spmfw'],
        'sspm': ['sspm_1', 'sspm_2'],
        'tee': ['tee1', 'tee2']
    }

    pl = 'preloader_ufs'
    pl_part = ['sda', 'sdb']

    # Initialize the firmware command to patch radio images
    fw_cmd = 'ui_print("Patching radio images unconditionally...");\n'
    
    # Add preloader image and patch it
    AddImageOnly(info, f"{pl}.img", incremental, firmware=True)
    fw_cmd += ''.join(f'package_extract_file("{pl}.img", "/dev/block/{part}");\n' for part in pl_part)

    # Add other images and patch them based on img_map
    for img, parts in img_map.items():
        AddImageOnly(info, f'{img}.img', incremental, firmware=True)
        fw_cmd += ''.join(f'package_extract_file("{img}.img", "/dev/block/platform/bootdevice/by-name/{part}");\n' for part in parts)

    # Add binary files and patch them based on bin_map
    for _bin, parts in bin_map.items():
        AddImageOnly(info, f'{_bin}.bin', incremental, firmware=True)
        fw_cmd += ''.join(f'package_extract_file("{_bin}.bin", "/dev/block/platform/bootdevice/by-name/{part}");\n' for part in parts)

    # Append the firmware patching command to the script
    info.script.AppendExtra(fw_cmd)

