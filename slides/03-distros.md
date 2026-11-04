---
layout: center
class: text-center
---

# Embedded Linux

## Distro World

---
layout: default
---

::title::

Embedded Linux Distro World

::body::

- [Android](https://source.android.com)
  - Great for systems with ARM-based SoCs and touch screens
  - Build system and development tools
  - Everything you need in the distro
- [Buildroot](https://buildroot.org/)
  - GNU Kconfig make build system
  - libc, uClibc, musl target libraries
  - Multiple packages and easy to use
- [Yocto](https://www.yoctoproject.org/)
  - Build system designed around BitBake tools
  - libc, musl, newlib support
  - … we will look at it during the course

---
layout: default
---

::title::

Embedded Linux Distro World

::body::

Each embedded design requires selecting the best distro:

- What to use to support tablet or mobile-phone-like embedded devices? (Android)
- What to use to support small-footprint devices based on Linux? (Buildroot)
- What is the best way to bootstrap a Linux device? (Buildroot)
- What about complex embedded devices including browser support, multi-application systems and multiple packages? (Yocto)
