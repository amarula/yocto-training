# Lab 08 — Kernel and U-Boot

## Goal

Inspect the kernel recipe and configuration, add a configuration fragment,
verify it on the target, and inspect the U-Boot configuration for the board.

## Inspect the kernel recipe

From the `labs/` directory:

```bash
./kas.sh shell kas/qemu.yml -c \
  "bitbake -e virtual/kernel | grep -E '^(LINUX_VERSION|KBRANCH|KMACHINE|KERNEL_FEATURES|SRC_URI)='"
```

The training layer already adds a fragment through
`meta-training/recipes-kernel/linux/linux-yocto_%.bbappend` and
`meta-training/recipes-kernel/linux/linux-yocto/training.cfg`.

## Build and verify on the target

```bash
./kas.sh build kas/qemu.yml
./kas.sh shell kas/qemu.yml -c 'runqemu qemux86-64 training-image'
```

On the target:

```bash
zcat /proc/config.gz | grep IKCONFIG
```

Expected:

```text
CONFIG_IKCONFIG=y
CONFIG_IKCONFIG_PROC=y
```

## Inspect the deployed kernel

For QEMU x86, the kernel is a `bzImage`:

```bash
ls -lh build/tmp/deploy/images/qemux86-64/bzImage*
```

For the i.MX8M Plus build, the kernel is an `Image` and the DTBs are deployed
next to it:

```bash
ls -lh build/tmp/deploy/images/imx8mp-lpddr4-evk/Image*
ls -lh build/tmp/deploy/images/imx8mp-lpddr4-evk/*.dtb
```

## Inspect U-Boot

Fetch the board layers and inspect the bootloader provider:

```bash
./kas.sh checkout kas/imx8mp.yml
./kas.sh shell kas/imx8mp.yml -c 'bitbake-layers show-recipes "u-boot*"'
./kas.sh shell kas/imx8mp.yml -c \
  "bitbake -e virtual/bootloader | grep -E '^(UBOOT_MACHINE|UBOOT_CONFIG|SPL_BINARY|UBOOT_BINARY|UBOOT_SUFFIX)='"
```

Look for:

- `UBOOT_MACHINE` — the board defconfig
- `SPL_BINARY` — the SPL path, e.g. `spl/u-boot-spl.bin`
- `UBOOT_BINARY` and `UBOOT_SUFFIX` — the U-Boot image name and format

## Challenge — change the kernel configuration

Add a line to `training.cfg`, for example:

```text
CONFIG_DEBUG_INFO_NONE=y
```

Rebuild, boot and verify:

```bash
./kas.sh build kas/qemu.yml
./kas.sh shell kas/qemu.yml -c 'runqemu qemux86-64 training-image'
zcat /proc/config.gz | grep DEBUG_INFO_NONE
```

Then remove the line and rebuild to restore the original configuration.

## Challenge — U-Boot fragment

Add a U-Boot `.cfg` fragment to `meta-training/recipes-bsp/u-boot/` and
append it to `SRC_URI` in a `u-boot_%.bbappend`. Inspect the resulting
configuration with `bitbake -e virtual/bootloader`.

## Validation

```bash
./scripts/check-lab.sh
```
