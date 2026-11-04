---
layout: center
class: text-center
---

# Yocto

## Kernel and U-Boot

---
layout: default
---

::title::

Kernel and bootloader are recipes

::body::

- The kernel is provided by `virtual/kernel`; the bootloader by `virtual/bootloader`.
- Select the providers in the machine or distro configuration:

```text
PREFERRED_PROVIDER_virtual/kernel = "linux-yocto"
PREFERRED_PROVIDER_virtual/bootloader = "u-boot"
```

- OE-Core provides `linux-yocto_6.18.bb` and `u-boot_2026.01.bb`.
- BSP layers provide vendor kernels and bootloaders, for example `linux-imx`, `u-boot-imx` and `u-boot-ti`.
- `PREFERRED_VERSION_linux-yocto = "6.18%"` selects a version when several are available.
- The machine configuration decides which kernel image, device tree and bootloader configuration are used.

---
layout: default
---

::title::

Kernel recipe anatomy

::body::

- `linux-yocto_6.18.bb` includes `linux-yocto.inc` and `kernel-yocto.bbclass`.
- Key variables:
  - `LINUX_VERSION`, `PV`
  - `SRC_URI`, `SRCREV`, `KBRANCH`, `KMACHINE`
  - `KERNEL_FEATURES`
  - `COMPATIBLE_MACHINE`
  - `KBUILD_DEFCONFIG`
- `SRC_URI` can point to a git tree, a tarball, patches and configuration fragments.
- `KBRANCH` and `KMACHINE` map the Yocto machine to a kernel meta branch.

---
layout: default
---

::title::

Kernel configuration

::body::

- A defconfig can come from the kernel tree or from the recipe:
  - `KBUILD_DEFCONFIG = "defconfig"`
  - `SRC_URI += "file://defconfig"`
- `.cfg` fragments are merged into the configuration:

```text
SRC_URI += "file://training.cfg"
```

- `KERNEL_FEATURES` applies kernel-yocto `.scc` and `.cfg` features:

```text
KERNEL_FEATURES:append = " features/debug/printk.scc"
```

- `KCONFIG_MODE` selects defconfig, allnoconfig or allyesconfig behavior (rarely needed).

---
layout: default
---

::title::

Editing the kernel configuration

::body::

- Open the interactive configuration:

```bash
bitbake -c menuconfig virtual/kernel
```

- Save the changes and generate a fragment:

```bash
bitbake -c diffconfig virtual/kernel
```

The fragment is written to `.config` in the kernel build directory; copy it into your layer as a `.cfg` file.

- Or save a full defconfig:

```bash
bitbake -c savedefconfig virtual/kernel
```

- Rebuild after adding the fragment:

```bash
bitbake virtual/kernel
```

---
layout: default
---

::title::

Config fragment example

::body::

`meta-training/recipes-kernel/linux/linux-yocto/training.cfg`:

```text
CONFIG_IKCONFIG=y
CONFIG_IKCONFIG_PROC=y
```

`meta-training/recipes-kernel/linux/linux-yocto_%.bbappend`:

```text
FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:"
SRC_URI:append = " file://training.cfg"
```

- The fragment is merged into the kernel `.config`.
- Verify it on the target with `zcat /proc/config.gz`.

---
layout: default
---

::title::

Device tree

::body::

- The machine configuration lists the DTBs to build:

```text
KERNEL_DEVICETREE = "freescale/imx8mp-icore-mx8mp-ctouch2-of10.dtb"
```

- DTBs are built from the kernel source and packaged in `kernel-devicetree`.
- `KERNEL_DEVICETREE_BUNDLE = "1"` appends the DTB to the kernel image for boards that need it.
- `KERNEL_DTC_FLAGS` passes extra flags to `dtc`.
- Add the DTB to the boot partition with `IMAGE_BOOT_FILES`.
- `devicetree.bbclass` builds out-of-tree device trees.

---
layout: default
---

::title::

Kernel modules

::body::

- In-tree modules are enabled with `CONFIG_* = m` and packaged as `kernel-module-<name>`.
- Autoload modules at boot:

```text
KERNEL_MODULE_AUTOLOAD += "mymodule"
```

- Out-of-tree module recipe:

```text
inherit module

SRC_URI = "file://mymodule.c"
S = "${UNPACKDIR}"
```

`module.bbclass` runs the kernel build system and packages the `.ko` file.

- Add the module package to the image with `IMAGE_INSTALL`.

---
layout: default
---

::title::

Kernel patches and devtool

::body::

- Patches are listed in `SRC_URI` and applied in order:

```text
SRC_URI += "file://0001-fix.patch"
```

- Use `devtool modify` to work on the source:

```bash
devtool modify linux-yocto
devtool build linux-yocto
devtool finish -a meta-training linux-yocto
```

- `bitbake -c devshell virtual/kernel` opens a shell in the kernel build directory.
- Keep patches small and upstream them when possible.

---
layout: default
---

::title::

U-Boot in Yocto

::body::

- OE-Core provides `u-boot_2026.01.bb`, `u-boot.inc` and `u-boot-configure.inc`.
- Key variables:
  - `UBOOT_MACHINE` — board defconfig
  - `UBOOT_CONFIG` — build several configurations
  - `SPL_BINARY` — SPL image path
  - `UBOOT_SUFFIX`, `UBOOT_BINARY`, `UBOOT_IMAGE`
- `PREFERRED_PROVIDER_virtual/bootloader = "u-boot"`.
- Vendor BSPs provide `u-boot-imx`, `u-boot-ti` and similar recipes.

---
layout: default
---

::title::

U-Boot configuration flow (6.0)

::body::

- Single configuration:

```text
UBOOT_MACHINE = "mx8mp_icore_ctouch2_defconfig"
```

- Multiple configurations use the flag syntax:

```text
UBOOT_MACHINE = ""
UBOOT_CONFIG ??= "sd"
UBOOT_CONFIG[sd] = "mx8mp_icore_ctouch2_defconfig"
UBOOT_CONFIG_FRAGMENTS[sd] = "training.cfg"
UBOOT_CONFIG_MAKE_OPTS[sd] = "FOO=1"
```

- `.cfg` fragments in `SRC_URI` are merged with `merge_config.sh`.
- The legacy comma-separated form (`UBOOT_CONFIG[sd] = "config,images,binary"`) is deprecated and will be removed after Wrynose.

---
layout: default
---

::title::

U-Boot bbappend example

::body::

`meta-training/recipes-bsp/u-boot/u-boot_%.bbappend`:

```text
FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:"
SRC_URI:append = " file://training.cfg"
```

`conf/machine/imx8mp-training.conf`:

```text
UBOOT_MACHINE = "mx8mp_icore_ctouch2_defconfig"
SPL_BINARY = "spl/u-boot-spl.bin"
```

- Build with:

```bash
bitbake virtual/bootloader
```

- Outputs include `u-boot.bin`, `u-boot-spl.bin` and the SPL/U-Boot image variants.

---
layout: default
---

::title::

FIT images

::body::

- A FIT image bundles the kernel, DTB, initramfs and configuration into one signed blob.
- In 6.0, build it with the companion recipe:

```bash
bitbake linux-yocto-fitimage
```

- The recipe inherits `kernel-fit-image`; the kernel must deploy extra artifacts:

```text
KERNEL_CLASSES += "kernel-fit-extra-artifacts"
```

- Key variables: `FIT_DESC`, `FIT_HASH_ALG`, `FIT_SIGN_ALG`, `FIT_KEY_SIGN_PKCS`, `FIT_SIGN_INDIVIDUAL`.
- Output: `fitImage-*` under `tmp/deploy/images/<machine>/`.

---
layout: default
---

::title::

Signing and secure boot

::body::

- Enable FIT signing:

```text
UBOOT_SIGN_ENABLE = "1"
UBOOT_SIGN_KEYDIR = "${TOPDIR}/keys"
UBOOT_SIGN_KEYNAME = "dev"
UBOOT_MKIMAGE_DTCOPTS = "-I dts -O dtb -p 2000"
```

- `FIT_SIGN_INDIVIDUAL = "0"` is recommended; signing each image individually is unusual.
- Kernel module signing is enabled through the kernel configuration:

```text
CONFIG_MODULE_SIG=y
CONFIG_MODULE_SIG_ALL=y
CONFIG_MODULE_SIG_KEY="certs/signing_key.pem"
```

- Secure boot also needs bootloader/ROM keys and board-specific fuse programming; see `meta-security` and the BSP documentation.

---
layout: default
---

::title::

Machine configuration

::body::

```text
PREFERRED_PROVIDER_virtual/kernel = "linux-yocto"
PREFERRED_VERSION_linux-yocto = "6.18%"
KERNEL_IMAGETYPE = "Image"
KERNEL_DEVICETREE = "freescale/imx8mp-icore-mx8mp-ctouch2-of10.dtb"

PREFERRED_PROVIDER_virtual/bootloader = "u-boot"
UBOOT_MACHINE = "mx8mp_icore_ctouch2_defconfig"
SPL_BINARY = "spl/u-boot-spl.bin"

IMAGE_BOOT_FILES = "Image imx8mp-icore-mx8mp-ctouch2-of10.dtb"
```

- Keep hardware details in the machine configuration and policy in the distro configuration.
- The BSP layer should document the board in its README.

---
layout: default
---

::title::

Build and inspect

::body::

```bash
bitbake virtual/kernel
bitbake virtual/bootloader
bitbake -c menuconfig virtual/kernel
bitbake -c diffconfig virtual/kernel
```

- Deploy directory: `tmp/deploy/images/<machine>/`
  - `Image`, `*.dtb`, `u-boot*.bin`, `fitImage-*`
- Work directories:
  - `tmp/work/<machine>/linux-yocto/<version>/`
  - `tmp/work/<machine>/u-boot/<version>/`
- Logs: `temp/log.do_compile`, `temp/log.do_configure`.
- `devtool modify linux-yocto` and `devtool modify u-boot` for source changes.

---
layout: default
---

::title::

Hands-on lab: kernel and U-Boot

::body::

- Lab: `labs/exercises/08-kernel-fragment.md`
- Build the kernel and inspect the fragment:

```bash
cd labs
./kas.sh build kas/qemu.yml
./kas.sh shell kas/qemu.yml -c 'bitbake -e virtual/kernel | grep ^KERNEL_FEATURES='
```

- Boot and verify:

```bash
zcat /proc/config.gz | grep IKCONFIG
```

- Inspect the deployed kernel and DTB:

```bash
ls build/tmp/deploy/images/qemux86-64/Image* build/tmp/deploy/images/qemux86-64/*.dtb
```

- Challenge: change the fragment, rebuild and compare the kernel configuration.
- U-Boot: inspect the recipe and variables with `bitbake -e u-boot`.

---
layout: default
---

::title::

Checkpoint: kernel and U-Boot

::body::

1. Which variables select the kernel and bootloader providers?
2. How do you add a kernel configuration fragment to a layer?
3. Where are the kernel image and DTB deployed?
4. What is the difference between `UBOOT_MACHINE` and `UBOOT_CONFIG`?
5. Why is `FIT_SIGN_INDIVIDUAL = "1"` discouraged?
