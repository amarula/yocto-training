# Lab 07 — Images and WIC

## Goal

Inspect the image outputs, the package manifest and the WIC layout, then
customize the image and the partition table.

## Build and inspect

From the `labs/` directory:

```bash
./kas.sh build kas/qemu.yml
```

Inspect the resolved image variables:

```bash
./kas.sh shell kas/qemu.yml -c \
  "bitbake -e training-image | grep -E '^(IMAGE_FSTYPES|IMAGE_INSTALL|IMAGE_FEATURES|WKS_FILE)='"
```

List the deploy directory:

```bash
ls -lh build/tmp/deploy/images/qemux86-64/
```

The package manifest lists every package in the root filesystem:

```bash
grep -E '^(hello|training-info|htop|strace) ' \
  build/tmp/deploy/images/qemux86-64/training-image-qemux86-64.rootfs.manifest
```

## Add packages

Add `htop` and `strace` to the training package group:

```diff
--- a/meta-training/recipes-core/packagegroups/packagegroup-training.bb
+++ b/meta-training/recipes-core/packagegroups/packagegroup-training.bb
@@
-RDEPENDS:${PN} = "hello training-info"
+RDEPENDS:${PN} = "hello training-info htop strace"
```

Rebuild and verify them in the manifest:

```bash
./kas.sh build kas/qemu.yml
grep -E '^(htop|strace) ' \
  build/tmp/deploy/images/qemux86-64/training-image-qemux86-64.rootfs.manifest
```

## Inspect the WIC image

The default layout is in `meta-training/files/wic/training.wks`:

```text
part / --source rootfs --fstype=ext4 --label root --align 4096
```

List the partitions in the generated image:

```bash
wic ls build/tmp/deploy/images/qemux86-64/training-image-qemux86-64.rootfs.wic
```

## Challenge — add a boot partition

Create a boot partition and copy the kernel into it:

```text
part /boot --source bootimg-partition --ondisk mmcblk0 --fstype=vfat \
     --label boot --active --align 4096 --size 64
part / --source rootfs --ondisk mmcblk0 --fstype=ext4 \
     --label root --align 4096 --size 1024
```

Set `IMAGE_BOOT_FILES` in `training-image.bb`:

```text
IMAGE_BOOT_FILES = "bzImage"
```

Rebuild and inspect the result:

```bash
./kas.sh build kas/qemu.yml
wic ls build/tmp/deploy/images/qemux86-64/training-image-qemux86-64.rootfs.wic
```

Note: the QEMU machine boots with `runqemu`, which does not require this boot
partition. On a real board, the BSP usually provides its own WIC layout and
bootloader flashing procedure.

## Validation

```bash
./scripts/check-lab.sh
```
