#!/usr/bin/env bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

echo "[1/4] Running ReSukiSU setup..."
curl -LSs "https://raw.githubusercontent.com/ReSukiSU/ReSukiSU/main/kernel/setup.sh" | bash

echo "[2/4] Downloading and patching susfs_patch_to_4.19.patch..."
curl -LSs "https://raw.githubusercontent.com/JackA1ltman/NonGKI_Kernel_Build_2nd/mainline/Patches/Patch/susfs_patch_to_4.19.patch" -o susfs_patch_to_4.19.patch
patch -p0 susfs_patch_to_4.19.patch < .github/patches/patch_for_susfs_4.19.patch

echo "[3/4] Applying patched SUSFS to kernel..."
patch -p1 < susfs_patch_to_4.19.patch
rm -f susfs_patch_to_4.19.patch

echo "[4/4] Running SUSFS inline hook patches..."
curl -LSs "https://raw.githubusercontent.com/JackA1ltman/NonGKI_Kernel_Build_2nd/mainline/Patches/susfs_inline_hook_patches.sh" | bash

echo "==> Setup and patching completed successfully!"
