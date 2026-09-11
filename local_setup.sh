#!/usr/bin/env bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

CLANG_DIR="$SCRIPT_DIR/clang-r530567"

echo "[1/5] Checking Clang 19 (clang-r530567)..."
if [ ! -f "$CLANG_DIR/bin/clang" ]; then
    echo "Clang 19 not found. Downloading..."
    mkdir -p "$CLANG_DIR"
    curl --retry 5 --retry-delay 3 --retry-all-errors -fSLo /tmp/clang-r530567.tar.gz \
        "https://android.googlesource.com/platform/prebuilts/clang/host/linux-x86/+archive/refs/heads/main/clang-r530567.tar.gz"
    echo "Extracting Clang 19..."
    tar -xzf /tmp/clang-r530567.tar.gz -C "$CLANG_DIR"
    rm -f /tmp/clang-r530567.tar.gz
    echo "Clang 19 installed to $CLANG_DIR"
else
    echo "Clang 19 is already installed in $CLANG_DIR."
fi

echo "[2/5] Running ReSukiSU setup..."
curl -LSs "https://raw.githubusercontent.com/ReSukiSU/ReSukiSU/main/kernel/setup.sh" | bash

echo "[3/5] Downloading and patching susfs_patch_to_4.19.patch..."
curl -LSs "https://raw.githubusercontent.com/JackA1ltman/NonGKI_Kernel_Build_2nd/mainline/Patches/Patch/susfs_patch_to_4.19.patch" -o susfs_patch_to_4.19.patch
patch -p0 susfs_patch_to_4.19.patch < .github/patches/patch_for_susfs_4.19.patch

echo "[4/5] Applying patched SUSFS to kernel..."
patch -p1 < susfs_patch_to_4.19.patch
rm -f susfs_patch_to_4.19.patch

echo "[5/5] Running SUSFS inline hook patches..."
curl -LSs "https://raw.githubusercontent.com/JackA1ltman/NonGKI_Kernel_Build_2nd/mainline/Patches/susfs_inline_hook_patches.sh" | bash

echo "==> Setup and patching completed successfully!"
