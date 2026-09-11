#!/usr/bin/env bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

FLAVOR="${1:-susfs-min}"

echo "========================================================="
echo " Setting up kernel flavor: $FLAVOR"
echo " (Options: susfs-min, susfs-full, manualhook, vanilla)"
echo "========================================================="

CLANG_DIR="$SCRIPT_DIR/clang-r530567"

echo "[1/4] Checking Clang toolchain..."
if [ ! -f "$CLANG_DIR/bin/clang" ]; then
    echo "Clang not found. Downloading..."
    mkdir -p "$CLANG_DIR"
    curl --retry 5 --retry-delay 3 --retry-all-errors -fSLo /tmp/clang.tar.gz \
        "https://android.googlesource.com/platform/prebuilts/clang/host/linux-x86/+archive/refs/heads/mirror-goog-main-llvm-toolchain-source/clang-r596125.tar.gz"
    echo "Extracting Clang..."
    tar -xzf /tmp/clang.tar.gz -C "$CLANG_DIR"
    rm -f /tmp/clang.tar.gz
fi

case "$FLAVOR" in
    susfs-min)
        echo "[2/4] Setting up ReSukiSU..."
        curl -LSs "https://raw.githubusercontent.com/ReSukiSU/ReSukiSU/main/kernel/setup.sh" | bash

        echo "[3/4] Downloading and applying SUSFS patches..."
        curl -LSs "https://raw.githubusercontent.com/JackA1ltman/NonGKI_Kernel_Build_2nd/mainline/Patches/Patch/susfs_patch_to_4.19.patch" -o susfs_patch_to_4.19.patch
        patch -p0 susfs_patch_to_4.19.patch < .github/patches/patch_for_susfs_4.19.patch
        patch -p1 < susfs_patch_to_4.19.patch
        rm -f susfs_patch_to_4.19.patch

        echo "[4/4] Applying SUSFS inline hooks..."
        curl -LSs "https://raw.githubusercontent.com/JackA1ltman/NonGKI_Kernel_Build_2nd/mainline/Patches/susfs_inline_hook_patches.sh" | bash
        echo "KBUILD_DIFFCONFIG=\"pdx213_diffconfig ksu_susfs_min.config\"" > .flavor_env
        ;;
    susfs-full)
        echo "[2/4] Setting up ReSukiSU..."
        curl -LSs "https://raw.githubusercontent.com/ReSukiSU/ReSukiSU/main/kernel/setup.sh" | bash

        echo "[3/4] Downloading and applying SUSFS patches..."
        curl -LSs "https://raw.githubusercontent.com/JackA1ltman/NonGKI_Kernel_Build_2nd/mainline/Patches/Patch/susfs_patch_to_4.19.patch" -o susfs_patch_to_4.19.patch
        patch -p0 susfs_patch_to_4.19.patch < .github/patches/patch_for_susfs_4.19.patch
        patch -p1 < susfs_patch_to_4.19.patch
        rm -f susfs_patch_to_4.19.patch

        echo "[4/4] Applying SUSFS inline hooks..."
        curl -LSs "https://raw.githubusercontent.com/JackA1ltman/NonGKI_Kernel_Build_2nd/mainline/Patches/susfs_inline_hook_patches.sh" | bash
        echo "KBUILD_DIFFCONFIG=\"pdx213_diffconfig ksu_susfs_full.config\"" > .flavor_env
        ;;
    manualhook)
        echo "[2/3] Setting up ReSukiSU..."
        curl -LSs "https://raw.githubusercontent.com/ReSukiSU/ReSukiSU/main/kernel/setup.sh" | bash

        echo "[3/3] Applying KSU manualhook patch..."
        patch -p1 < .github/patches/manualhook.patch
        echo "KBUILD_DIFFCONFIG=\"pdx213_diffconfig ksu_manual.config\"" > .flavor_env
        ;;
    vanilla)
        echo "Vanilla flavor selected: skipping all root/KSU hooks."
        echo "KBUILD_DIFFCONFIG=\"pdx213_diffconfig\"" > .flavor_env
        ;;
    *)
        echo "Unknown flavor: $FLAVOR. Valid options: susfs-min, susfs-full, manualhook, vanilla"
        exit 1
        ;;
esac

echo "==> Setup completed successfully for flavor: $FLAVOR!"
