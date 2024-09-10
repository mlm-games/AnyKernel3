#!/bin/bash

# Set variables
ANYKERNEL_REPO="https://github.com/mlm-games/AnyKernel3.git"
ANYKERNEL_DIR="AnyKernel3"
KERNEL_SOURCE_DIR=".."  # Replace with actual path
FINAL_KERNEL_ZIP="RuskKernel.zip"

# Clone AnyKernel3 repository
git clone "$ANYKERNEL_REPO" "$ANYKERNEL_DIR" depth=1

# Function to find and copy kernel image
copy_kernel_image() {
    local boot_dir="$KERNEL_SOURCE_DIR/arch"
    local kernel_image=""

    for arch in arm arm64; do
        if [ -d "$boot_dir/$arch/boot" ]; then
            # Search for kernel images in order of preference
            for img in zImage-dtb Image.gz-dtb Image.gz Image kernel; do
                kernel_image=$(find "$boot_dir/$arch/boot" -name "$img" | head -n 1)
                if [ -n "$kernel_image" ]; then
                    cp "$kernel_image" "$ANYKERNEL_DIR/"
                    echo "Copied kernel image: $kernel_image"
                    return 0
                fi
            done
        fi
    done

    echo "No kernel image found"
    return 1
}

# Function to find and copy one DTB/DTBO file
copy_dtb_dtbo() {
    local boot_dir="$KERNEL_SOURCE_DIR/arch"
    local dtb_file=""

    for arch in arm arm64; do
        if [ -d "$boot_dir/$arch/boot/dts" ]; then
            # Search for DTB/DTBO files
            dtb_file=$(find "$boot_dir/$arch/boot/dts" -name "*.dtb" -o -name "*.dtbo" | head -n 1)
            if [ -n "$dtb_file" ]; then
                cp "$dtb_file" "$ANYKERNEL_DIR/"
                echo "Copied DTB/DTBO file: $dtb_file"
                return 0
            fi
        fi
    done

    echo "No DTB/DTBO file found"
    return 0  # Return 0 even if no file found, as it's optional
}

# Main execution
copy_kernel_image
copy_dtb_dtbo

# Create AnyKernel zip
cd "$ANYKERNEL_DIR"
zip -r9 "$FINAL_KERNEL_ZIP" * -x .git README.md kernel_zipper.sh *placeholder

echo "AnyKernel zip created: $FINAL_KERNEL_ZIP"
