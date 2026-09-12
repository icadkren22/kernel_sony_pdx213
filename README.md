# KeepTenAlive

Custom kernel for the Sony Xperia 10 III (`pdx213`).

**KeepTenAlive** is made with the goal of keeping the Sony Xperia 10 III relevant as time goes by. I will slowly backport features from newer kernel versions without touching the userspace, while making sure the stock vendor remains compatible with the modifications I make.

---

## Overview

Basic stock kernel with several flavors of [ReSukiSU](https://github.com/ReSukiSU/ReSukiSU) + [SuSFS](https://gitlab.com/simonpunk/susfs4ksu), along with some additional storage features such as CIFS, NFS, NBD, and Btrfs. It also includes stability fixes from upstream and backports from newer kernel versions, built with **Android Clang 22 (`clang-r596125`)** using `-O3` optimization.

---

## Installation

1. Use firmware **62.2.A.0.525 – 62.2.A.0.548**.
2. Download the desired kernel zip from the [Releases](https://github.com/icadkren22/kernel_sony_pdx213/releases) page.
3. Extract the `.zip` archive to get the `.img` file.
4. Flash it through Fastboot or any other tools.
5. Reboot your device. The kernel just works.

---

## Details

- **Device**: Sony Xperia 10 III, using XQ-BT52 as base, but tested only in Xperia 10 III Lite (XQ-BT44, JP Ver Rakuten)
- **Base**: XQ-BT52 SEA `62.2.A.0.548` boot.img and kernel source
- **Techpack Source**: `62.0.A.3.131` kernel source
- **Compiler**: Android Clang 22 (`clang-r596125` / LLVM 22) with `-O3` optimization
- **Flavors**:
  - `susfs-full`: ReSukiSU + SuSFS 2.3 (all stealth features enabled)
  - `susfs-min`: ReSukiSU + SuSFS 2.3 (minimal mount hiding & logging)
  - `manualhook`: ReSukiSU Manual Hook (without SuSFS)
  - `vanilla`: Clean stock kernel without root hooks

### Additional Drivers & Subsystems Added

- **Network & Storage Filesystems**:
  - **CIFS / SMB** (`CONFIG_CIFS=y`): Samba / Windows network share client with legacy dialect support.
  - **NFS Client & Server** (`CONFIG_NFS_FS=y`, `CONFIG_NFSD=y`): Network File System v2, v3, and v4 (v4.1 / v4.2) with pNFS and ACL support.
  - **Btrfs** (`CONFIG_BTRFS_FS=y`): Copy-on-Write (CoW) filesystem with compression and POSIX ACL support.
  - **SquashFS** (`CONFIG_SQUASHFS=y`): Compressed read-only filesystem with ZSTD, XZ, LZ4, LZO, and ZLIB decompressors.
- **Block Devices & Caching**:
  - **NBD** (`CONFIG_BLK_DEV_NBD=y`): Network Block Device with upstream backports and stability/panic fixes.
  - **DM-Cache & DM-Writecache** (`CONFIG_DM_CACHE=y`, `CONFIG_DM_WRITECACHE=y`): Device-mapper caching layers (`dm-cache`, `dm-bufio`, `dm-writecache`) with upstream concurrency fixes.

---

## Sources

- [Sony Open Devices Program (SODP)](https://opendevices.sony.net/) & [Sony Developer World](https://developer.sony.com/open-source/aosp-on-xperia-open-devices)
- [ReSukiSU Repository](https://github.com/ReSukiSU/ReSukiSU)
- [2nd Non-GKI Kernel Build (JackA1ltman)](https://github.com/JackA1ltman/NonGKI_Kernel_Build_2nd)

---

## Acknowledgments & Special Thanks

- **[simonpunk](https://gitlab.com/simonpunk/susfs4ksu)** — for creating and maintaining SuSFS (`susfs4ksu`).
- **[tiann](https://github.com/tiann)** — for creating the KernelSU project.
- **[ReSukiSU Team & Contributors](https://github.com/ReSukiSU/ReSukiSU)** — for extending KernelSU with enhanced hooks, features, and manager.
- **[Sony Open Devices Program (SODP)](https://opendevices.sony.net/)** — for providing open kernel sources and supporting the developer community.
- **[JackA1ltman](https://github.com/JackA1ltman)** — for the Non-GKI kernel build templates and SuSFS 4.19 inline hook patches.
- **[topjohnwu](https://github.com/topjohnwu)** & **[Uevo001](https://github.com/Uevo001/magiskboot-linux)** — for `magiskboot`, enabling automated fastboot-compatible boot image repacking in CI.
- **The Linux Kernel Community** — for upstream stability fixes and open-source contributions.
