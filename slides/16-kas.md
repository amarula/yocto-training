---
layout: default
---

::title::

Yocto How handle complex release using KAS

::body::

- KAS is a tool designed by Siemens.
- KAS is used to fetch and build Yocto releases.
- The configuration file is a single YAML or JSON file.
- It can be run inside a Docker container.
- It is able to automatically generate `local.conf` and `bblayers.conf`.

---
layout: default
---

::title::

Yocto How handle complex release using KAS

::body::

```yaml
header:
  version: 8

machine: px30-engicam-px30-core-ctouch2
distro: rockchip-distro-wayland
target: rockchip-media

repos:
  meta-rockchip:
  poky:
    url: "https://git.yoctoproject.org/git/poky"
    refspec: hardknott
    layers:
      meta:
      meta-poky:
      meta-yocto-bsp:
  meta-openembedded:
    url: "https://github.com/openembedded/meta-openembedded.git"
    refspec: hardknott
    layers:
      meta-oe:
      meta-python:
      meta-networking:
      meta-multimedia:
```

---
layout: default
---

::title::

Yocto How handle complex release using KAS

::body::

```yaml
  meta-arm:
    url: "https://git.yoctoproject.org/git/meta-arm.git"
    refspec: hardknott
    layers:
      meta-arm-bsp:
      meta-arm:
      meta-arm-toolchain:

bblayers_conf_header:
  standard: |
    POKY_BBLAYERS_CONF_VERSION = "2"
    BBPATH = "${TOPDIR}"
    BBFILES ?= ""

local_conf_header:
  custom: |
    AUTHOR = "Jagan Teki <jagan@amarulasolutions.com>"
    IMAGE_FEATURES:append = " debug-tweaks weston"
    # u-boot, linux
    PREFERRED_PROVIDER_virtual/kernel = "linux-next"
    PREFERRED_VERSION_linux-next ?= "v5.14-%"
    PREFERRED_PROVIDER_u-boot = "u-boot"
    PREFERRED_VERSION_u-boot ?= "v2021.07"
    PREFERRED_PROVIDER_virtual/bootloader = "u-boot"
```

- `local_conf_header` defines our `local.conf`.
- `bblayers_conf_header` defines our `bblayers.conf`.

---
layout: default
---

::title::

Yocto How handle complex release using KAS

::body::

- We can build Yocto using KAS:
  - `kas build meta-custom/mymachine.yaml`
- Or, alternatively, invoke BitBake commands:
  - `kas shell /path/to/kas-project.yml -c 'bitbake dosfsutils-native'`

KAS is a way to organize complex Yocto projects. It's important to mention that after we establish the build directory we can always source the environment and use standard BitBake commands. KAS is a wrapper of the BitBake executor.
