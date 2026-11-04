---
layout: center
class: text-center
---

# Yocto

## Classes

---
layout: default
---

::title::

Yocto classes

::body::

- Classes provide an abstraction to common code, which can be reused in multiple recipes.
- Common tasks do not have to be re-developed!
- Any metadata and task that can be put in a recipe can be used in a class.
- The class extension is `.bbclass`.
- Classes are located in the `classes` directory of a layer.
- Recipes can use this common code by inheriting a class:
  - `inherit <class>`

---
layout: default
---

::title::

Yocto classes

::body::

OE-Core provides classes under `meta/classes-recipe`, `meta/classes-global` and `meta/classes`. What can a class implement? Just a few examples:

- `cmake.bbclass`
- `autotools.bbclass`
- `kernel.bbclass`
- …

A class groups a series of functionality that can be used by a recipe.

---
layout: default
---

::title::

Yocto classes usage inside a recipe

::body::

```text
SUMMARY = "Small and friendly console text editor"
DESCRIPTION = "GNU nano is an enhanced clone of the Pico text editor."
HOMEPAGE = "https://www.nano-editor.org/"
LICENSE = "GPL-3.0-only"
LIC_FILES_CHKSUM = "file://COPYING;md5=f27defe1e96c2e1ecd4e0c9be8967949"
DEPENDS = "ncurses"
RDEPENDS:${PN} = "ncurses-terminfo-base"

PV_MAJOR = "${@d.getVar('PV').split('.')[0]}"

SRC_URI = "https://nano-editor.org/dist/v${PV_MAJOR}/nano-${PV}.tar.xz"
SRC_URI[sha256sum] = "9f384374b496110a25b73ad5a5febb384783c6e3188b37063f677ac908013fde"

inherit autotools gettext pkgconfig
```

---
layout: default
---

::title::

Yocto classes

::body::

As you can see in the example above, the package `nano` uses the autotools class.

- The class helps us define the tasks.
- If the recipe does not define the tasks, those are obtained from the class that is included.
- `autotools.bbclass` will include the tasks:
  - `do_configure`
  - `do_build`
  - `do_install`
  - …

When a package is well written using standard tools, customization at Yocto level to append some extra steps is not needed.

---
layout: default
---

::title::

Yocto classes

::body::

Anyway, a recipe by default inherits the `base` class automatically.

- Defines basic common tasks with a default implementation:
  - fetch, unpack, patch
  - configure, compile, install
  - Utility tasks such as: clean, listtasks
- Automatically applies patch files listed in `SRC_URI`.
- Defines mirrors: `SOURCEFORGE_MIRROR`, `DEBIAN_MIRROR`, `GNU_MIRROR`, `KERNELORG_MIRROR`…
- Defines `oe_runmake`, using `EXTRA_OEMAKE` to use custom arguments.

---
layout: default
---

::title::

Yocto kernel.bbclass

::body::

Let's dive into `kernel.bbclass`:

- Used to build Linux kernels.
- Defines tasks to configure, compile and install the kernel and its modules.
- Automatically applies a defconfig listed in `SRC_URI`:
  - `SRC_URI += "file://defconfig"`
- The kernel is divided into several packages: `kernel`, `kernel-base`, `kernel-dev`, `kernel-modules`…
- Automatically provides the virtual package `virtual/kernel`.
- Configuration variables are available:
  - `KERNEL_IMAGETYPE`, defaults to `zImage`
  - `KERNEL_EXTRA_ARGS`
  - `INITRAMFS_IMAGE`

---
layout: default
---

::title::

Yocto kernel.bbclass

::body::

An example of how to use it:

```text
require recipes-kernel/linux/linux-imx.inc
LICENSE = "GPL-2.0-only"
LIC_FILES_CHKSUM = "file://COPYING;md5=6bc538ed5bd9a7fc9398086aedcd7e46"
LINUX_VERSION = "6.18"
SRC_URI = "git+https://git.kernel.org/pub/scm/linux/kernel/git/next/linux-next.git;branch=${SRCBRANCH} \
           file://0001-arm64-dts-freescale-Add-Engicam-i.Core-MX8M-Plus-C.T.patch \
           file://0002-dt-bindings-arm-fsl-Add-Engicam-i.Core-MX8M-Plus-C.T.patch \
           file://${THISDIR}/files/fsl-ctouch-display-enable.cfg \
           file://${THISDIR}/files/fsl-gpu-imx8mp-enable.cfg \
          "
LOCALVERSION = "-2.2.0+yocto"
SRCBRANCH = "master"
SRCREV = "44c026a73be8038f03dbdeef028b642880cf1511"
DEPENDS += "lzop-native bc-native"
COMPATIBLE_MACHINE = "(imx8mp-icore-ctouch2-of10)"
KBUILD_DEFCONFIG ?= "defconfig"
```

---
layout: default
---

::title::

Yocto kernel.bbclass

::body::

An example of how to use it:

As we can see, the recipe requires `linux-imx.inc`. As we discussed, the common part of recipes can be put inside an `.inc` file. So who is including `kernel.bbclass`?

Answer: `linux-imx.inc`

```text
inherit kernel-yocto kernel fsl-kernel-localversion fsl-vivante-kernel-driver-handler
```

and much more.

---
layout: default
---

::title::

Yocto kernel.bbclass

::body::

We said that we need to define some variables in order to pack the kernel. Those variables are inside the machine configuration file:

```text
# Kernel configuration
PREFERRED_PROVIDER_virtual/kernel ??= "linux-imx8mp-icore"
KERNEL_DEVICETREE = "freescale/imx8mp-icore-mx8mp-ctouch2-of10.dtb \
                    "
KERNEL_IMAGETYPE = "Image"
RRECOMMENDS:${KERNEL_PACKAGE_NAME}-base = ""
```

The classes included in the recipe will use the variables and pass them to all classes in order to package the kernel.

---
layout: default
---

::title::

Yocto cmake.bbclass

::body::

- The `cmake` class allows for recipes that need to build software using the CMake build system.
- You can use the `EXTRA_OECMAKE` variable to specify additional configuration options to be passed using the cmake command line.
- On the occasion that you are installing custom CMake toolchain files supplied by the application being built, you should install them to the preferred CMake module directory: `${D}${datadir}/cmake/Modules` during `do_install`.

---
layout: default
---

::title::

Yocto cmake.bbclass example

::body::

`meta/recipes-graphics/jpeg/libjpeg-turbo_3.1.3.bb`

This JPEG recipe inherits `cmake`:

```text
inherit cmake pkgconfig
```

The `cmake` class already includes all the steps to install libjpeg-turbo, so specializations of the tasks are not needed.

---
layout: default
---

::title::

Yocto class bin_package

::body::

- In some cases you only need to install pre-built files into the generated root filesystem. Examples are commercial libraries, pre-built artifacts coming from artifact storage, specific firmware for FPGA or external components, etc.
- `bin_package.bbclass` makes it simple to disable tasks that are not needed, like configure and compile, and provides a default `do_install` method.

---
layout: default
---

::title::

Yocto class bin_package implementation

::body::

We can go a bit deeper into this class, given its simple implementation:

```text
# Skip the unwanted steps
do_configure[noexec] = "1"
do_compile[noexec] = "1"

# Install the files to ${D}
bin_package_do_install () {
    # Do it carefully
    [ -d "${S}" ] || exit 1
    if [ -z "$(ls -A ${S})" ]; then
        bbfatal bin_package has nothing to install. Be sure the SRC_URI unpacks into S.
    fi
    cd ${S}
    install -d ${D}${base_prefix}
    tar --no-same-owner --exclude='./patches' --exclude='./.pc' -cpf - . \
        | tar --no-same-owner -xpf - -C ${D}${base_prefix}
}
FILES:${PN} = "/"
EXPORT_FUNCTIONS do_install
```
