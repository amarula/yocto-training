---
layout: center
class: text-center
---

# Yocto

## Images

---
layout: default
---

::title::

Yocto Images

::body::

The final goal of Yocto is to produce images for the target. How can this be achieved?

- An image is the top-level recipe and is used alongside the machine definition.
- Whereas the machine describes the hardware used and its capabilities, the image is architecture-agnostic and defines how the root filesystem is built, with what packages.
- By default, several images are provided in openembedded-core:
  - `meta*/recipes*/images/*.bb`

---
layout: default
---

::title::

Yocto Common Images

::body::

Yocto already provides common images. They can be used as a base for a distribution or to generate a minimal filesystem that allows testing the platform:

- `core-image-minimal`: small image, capable of booting a device.
- `core-image-base`: console-only image, with full hardware support.
- `core-image-full-cmdline`: console image with a full command-line environment.
- `core-image-weston`: image with basic Wayland support.
- `core-image-rt`: `core-image-minimal` with real-time tools and test suite.

---
layout: default
---

::title::

Image recipes and tasks

::body::

Images are recipes that inherit the `core-image` class. What tasks should the core image class implement?

- `do_rootfs` prepares all the packages to install and populates the final rootfs, taking into account what we ask to include/exclude in the final image.
- `do_image` generates the image.
- `do_image_complete` is used for post-processing commands.

And we need to exclude some of the common steps:

```text
do_fetch[noexec] = "1", do_unpack[noexec] = "1", do_patch[noexec] = "1",
do_configure[noexec] = "1"
do_compile[noexec] = "1", do_install[noexec] = "1"
do_package[noexec] = "1"
```

---
layout: default
---

::title::

Image variables

::body::

| Variable | Description |
| --- | --- |
| `IMAGE_BASENAME` | the name of the output image files. Defaults to `${PN}`. |
| `IMAGE_INSTALL` | packages and package groups to install in the image. |
| `IMAGE_FEATURES` | image-level features to enable. |
| `IMAGE_FSTYPES` | filesystem and disk image formats to generate. |
| `IMAGE_ROOTFS_SIZE` | root filesystem size in KiB. |
| `IMAGE_ROOTFS_EXTRA_SPACE` | extra KiB added to the root filesystem. |
| `IMAGE_OVERHEAD_FACTOR` | multiplier applied to the calculated size. |
| `IMAGE_LINGUAS` | languages to include. |
| `IMAGE_PKGTYPE` | package type used for the image. |
| `IMAGE_POSTPROCESS_COMMAND` | commands to run after image generation. |
| `EXTRA_IMAGEDEPENDS` | additional dependencies for the image. |

---
layout: default
---

::title::

IMAGE_INSTALL and packagegroups

::body::

- `IMAGE_INSTALL` is the package list for the image.
- Add packages in the image recipe:

```text
IMAGE_INSTALL:append = " htop strace"
```

- `CORE_IMAGE_EXTRA_INSTALL` adds packages without overriding `IMAGE_INSTALL`:

```text
CORE_IMAGE_EXTRA_INSTALL += " htop strace"
```

- Package groups group related packages:

```text
inherit packagegroup

RDEPENDS:${PN} = "hello training-info"
```

- Then add `packagegroup-training` to `IMAGE_INSTALL`.
- Prefer an image recipe or a distro layer over ad-hoc `local.conf` changes.

---
layout: default
---

::title::

IMAGE_FEATURES and EXTRA_IMAGE_FEATURES

::body::

- `IMAGE_FEATURES` enables image-level features in the recipe:

```text
IMAGE_FEATURES:append = " ssh-server-openssh"
```

- `EXTRA_IMAGE_FEATURES` is the `local.conf` interface for the same features:

```text
EXTRA_IMAGE_FEATURES = "allow-empty-password empty-root-password allow-root-login"
```

- Common features:
  - `ssh-server-openssh`, `package-management`
  - `read-only-rootfs`, `overlayfs-etc`
  - `dev-pkgs`, `dbg-pkgs`, `tools-sdk`
- `debug-tweaks` is split into `allow-empty-password`, `empty-root-password`, `allow-root-login` and `serial-autologin-root`.

---
layout: default
---

::title::

IMAGE_FSTYPES

::body::

- `IMAGE_FSTYPES` selects the output formats:

```text
IMAGE_FSTYPES:append = " wic"
```

- Common types:
  - `tar.zst` — the default root filesystem archive
  - `ext4`, `ext4.zst`
  - `wic`, `wic.zst`
  - `cpio.gz` — initramfs
  - `squashfs` — read-only filesystem
  - `fitImage` — FIT image
- Machine and distro layers can change the default; x86 machines use `wic.zst`.
- Remove a format with `IMAGE_FSTYPES:remove = " tar.zst"`.
- Output is under `tmp/deploy/images/<machine>/`.

---
layout: default
---

::title::

WIC and .wks

::body::

- WIC creates a partitioned disk image from a `.wks` kickstart file.
- `WKS_FILE` selects the layout; WIC searches `files/wic/` in the layers:

```text
WKS_FILE = "training.wks"
```

- Build the image with:

```text
IMAGE_FSTYPES:append = " wic"
```

- WIC plugins:
  - `rootfs` — the root filesystem
  - `bootimg-partition` — boot files from `IMAGE_BOOT_FILES`
  - `bootimg-efi` — EFI boot files
  - `rawcopy` — raw bootloader blobs
- Since Yocto 6.0, WIC is maintained as a separate project; OE-Core provides the `wic` recipe and `image_types_wic` class.

---
layout: default
---

::title::

A .wks example

::body::

QEMU, single rootfs partition:

```text
part / --source rootfs --fstype=ext4 --label root --align 4096
```

Board with a boot partition:

```text
part /boot --source bootimg-partition --ondisk mmcblk0 --fstype=vfat \
     --label boot --active --align 4096 --size 64
part / --source rootfs --ondisk mmcblk0 --fstype=ext4 \
     --label root --align 4096 --size 1024
```

- `--source` selects the plugin, `--fstype` the filesystem.
- `--size` is in MiB, `--align` is in KiB.
- `bootimg-partition` copies `IMAGE_BOOT_FILES` into `/boot`.

---
layout: default
---

::title::

IMAGE_BOOT_FILES

::body::

- `IMAGE_BOOT_FILES` lists the files copied to the boot partition:

```text
IMAGE_BOOT_FILES = "Image imx8mp-icore.dtb"
```

- For U-Boot and other bootloader artifacts:

```text
IMAGE_BOOT_FILES = "u-boot.bin"
```

- Rename a file with `file;destination`:

```text
IMAGE_BOOT_FILES = "Image;kernel.bin"
```

- `IMAGE_EFI_BOOT_FILES` is the equivalent for `bootimg-efi`.
- Many BSPs write the bootloader at a fixed offset; use the BSP's WIC plugin or `rawcopy` in that case.

---
layout: default
---

::title::

Flashing and booting

::body::

- QEMU:

```bash
runqemu qemux86-64 training-image
```

- Flash a WIC image to an SD card:

```bash
lsblk
sudo bmaptool copy training-image.wic /dev/sdX
```

- Or use `dd`:

```bash
sudo dd if=training-image.wic of=/dev/sdX bs=4M conv=fsync
```

- `bmaptool` can generate a block map and use it for a faster, verified write:

```bash
bmaptool create -o training-image.wic.bmap training-image.wic
sudo bmaptool copy --bmap training-image.wic.bmap training-image.wic /dev/sdX
```

- Always verify the target device with `lsblk` before writing.

---
layout: default
---

::title::

Read-only rootfs and overlayfs

::body::

- A read-only root filesystem protects the system and simplifies updates:

```text
IMAGE_FEATURES:append = " read-only-rootfs"
```

- `overlayfs-etc` keeps `/etc` writable on top of a read-only rootfs:

```text
IMAGE_FEATURES:append = " overlayfs-etc"
OVERLAYFS_ETC_DEVICE = "/dev/mmcblk0p3"
OVERLAYFS_ETC_MOUNT_POINT = "/data"
OVERLAYFS_ETC_FSTYPE = "ext4"
```

- The writable partition must be created by the WIC layout or the BSP.
- `overlayfs-etc` conflicts with `package-management` when the original init name is used.

---
layout: default
---

::title::

Image size and inspection

::body::

- Control the root filesystem size:

```text
IMAGE_ROOTFS_SIZE = "65536"        # KiB
IMAGE_ROOTFS_EXTRA_SPACE = "16384" # KiB
IMAGE_OVERHEAD_FACTOR = "1.3"
```

- Inspect the result:

```bash
du -sh tmp/deploy/images/<machine>/<image>*
cat tmp/deploy/images/<machine>/<image>.rootfs.manifest
oe-pkgdata-util list-pkg-files -p hello
```

- License manifest: `tmp/deploy/licenses/<image>/license.manifest`
- SBOM: `tmp/deploy/spdx/`
- `INHERIT += "rm_work"` saves disk space; use `RM_WORK_EXCLUDE` for recipes you debug.
- `buildhistory` tracks image and package changes; `buildhistory-diff` shows them.

---
layout: default
---

::title::

Hands-on lab: images and WIC

::body::

- Lab: `labs/exercises/07-image-and-wic.md`
- Build the training image:

```bash
cd labs
./kas.sh build kas/qemu.yml
```

- Inspect the manifest and the WIC image:

```bash
cat build/tmp/deploy/images/qemux86-64/training-image-qemux86-64.rootfs.manifest
ls -lh build/tmp/deploy/images/qemux86-64/training-image-qemux86-64.rootfs.wic
```

- Challenge: add `htop` and `strace` to the image, rebuild and verify them in the manifest.
- Challenge: add a 64 MiB boot partition to `training.wks` and inspect the result with `wic ls`.

---
layout: default
---

::title::

Checkpoint: images

::body::

1. What is the difference between `IMAGE_INSTALL` and `IMAGE_FEATURES`?
2. What does `WKS_FILE` control, and where is it searched?
3. How does `bootimg-partition` know which files to copy?
4. How do you make the root filesystem read-only while keeping `/etc` writable?
5. Where do you find the package manifest and the license manifest?
