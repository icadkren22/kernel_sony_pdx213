#!/usr/bin/env bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

# Toolchain and output paths
CLANG_DIR="/home/ica2322/sus/clang-r530567"
OUT_DIR="$SCRIPT_DIR/out"
ARTIFACTS_DIR="$SCRIPT_DIR/build-artifacts"

export PATH="$CLANG_DIR/bin:$PATH"

echo "=== Clang Toolchain ==="
clang --version

echo "=== Generating Kernel Configuration ==="
mkdir -p "$OUT_DIR"
make ARCH=arm64 O="$OUT_DIR" \
     CC=clang LLVM=1 LLVM_IAS=1 CLANG_TRIPLE="aarch64-linux-gnu-" \
     CROSS_COMPILE="aarch64-linux-gnu-" \
     TARGET_BUILD_VARIANT=user \
     vendor/lito-perf_defconfig KBUILD_DIFFCONFIG=pdx213_diffconfig

echo "=== Compiling Kernel ==="
make ARCH=arm64 O="$OUT_DIR" \
     CC=clang LLVM=1 LLVM_IAS=1 CLANG_TRIPLE="aarch64-linux-gnu-" \
     CROSS_COMPILE="aarch64-linux-gnu-" \
     TARGET_BUILD_VARIANT=user \
     -j$(nproc)

echo "=== Repacking boot.img via magiskboot ==="
mkdir -p "$ARTIFACTS_DIR"

# Decompress base stock boot image
gunzip -c boot_X-FLASH-ALL-8A63.img.gz > "$ARTIFACTS_DIR/stock_boot.img"

mkdir -p bootimg-work
cp "$ARTIFACTS_DIR/stock_boot.img" bootimg-work/boot.img
cd bootimg-work
"$SCRIPT_DIR/magiskboot" unpack boot.img

# Replace kernel Image with newly compiled one
cp "$OUT_DIR/arch/arm64/boot/Image" kernel
"$SCRIPT_DIR/magiskboot" repack boot.img "$ARTIFACTS_DIR/boot.img"

cd "$SCRIPT_DIR"
rm -rf bootimg-work "$ARTIFACTS_DIR/stock_boot.img"

echo "=== Copying Artifacts ==="
cp "$OUT_DIR/arch/arm64/boot/Image" "$ARTIFACTS_DIR/Image"
mkdir -p "$ARTIFACTS_DIR/modules"
find "$OUT_DIR" -name "*.ko" -exec cp {} "$ARTIFACTS_DIR/modules/" \; 2>/dev/null || true

echo "=== Build Complete! ==="
echo "Artifacts generated in: $ARTIFACTS_DIR"
ls -lh "$ARTIFACTS_DIR"
