---
layout: center
class: text-center
---

# Yocto

## Basics

---
layout: default
---

::title::

Let's start with the basic

::body::

- How to set up the environment.
- What are the common targets and how to deal with them.
- Exported environment and their usage.
- The available commands.
- The organization of the build directory.

---
layout: default
---

::title::

How to setup environment (1 / 3)

::body::

- All the build files are organized in a specific build directory.
- Any build does not touch anything we have downloaded from the internet.
- Don't apply any change to poky core or any layer that is used by you.
- You need only to use a script to define where you want your system to be built.
- `oe-init-build-env` is used to define the environment and set the build directory.

---
layout: default
---

::title::

How to setup environment (2 / 3)

::body::

`oe-init-build-env` needs to be sourced in order to start:

```bash
source ./oe-init-build-env [builddir]
```

After the file is sourced, you'll land in the `[builddir]`. The build directory already contains the basic Yocto Project structure. If the build directory is missing, the default build directory is built.

After you source the environment, all the `bitbake*` family commands will be available in the console.

---
layout: default
---

::title::

How setup environment (3 / 3)

::body::

Do you like a toast? Toaster is a graphical web UI that can be used in Yocto. An example to install and launch it:

```bash
pip3 install --user -r bitbake/toaster-requirements.txt
source oe-init-build-env
source toaster start
```

The Toaster interface is now available on [http://127.0.0.1:8000](http://127.0.0.1:8000).

---
layout: default
---

::title::

The build directory structure

::body::

```text
tree -L 1
.
├── buildhistory
├── cache
├── conf
├── downloads
├── sstate-cache
└── tmp
```

- `buildhistory`: records information about the contents of each package and image and commits that information to a local Git repository
- `sstate-cache`: stores build information for all the builds, and is used to fast-rebuild or easily rebuild images.
- `tmp`: all build system output.
- `conf`: holds your build configuration files, including the meta-layers you need and all machine configurations.
- `cache`: contains BitBake hashing and internal databases.

---
layout: default
---

::title::

The build tmp directory

::body::

```text
tree -L 1
.
├── deploy
├── sysroots-components
├── sysroots-uninative
└── work
```

- `deploy`: stores build artifacts including images and SDK.
- `sysroot-components`: is the list of each recipe's artifacts to be placed in the target rootfs or in the build rootfs in case of "native".
- `sysroot-uninative`: is the toolchain shared libraries portion of the build rootfs.
- `work`: is a set of recipe build result artifacts including recipe dependencies.

---
layout: default
---

::title::

Configure the build system

::body::

As we said, the `conf` directory contains the configuration files:

- `bblayers.conf`: the bblayer configuration file lists all the layers needed for that particular product. Layers are the building blocks used to compose the image.
- `local.conf`: sets configuration variables related to the current user for the build. Configuration variables can be overridden there.

---
layout: default
---

::title::

Configure the build system

::body::

Let's start from `local.conf`. This file contains a lot of variables that can be used to tune the build system and to override specific distribution build parameters. The most important variables to tune our build system are:

- `BB_NUMBER_THREADS`: how many tasks BitBake should perform in parallel. Defaults to the number of CPU threads on the system. (Note: if you use your laptop, set it to a number of threads that does not burn your machine.)
- `PARALLEL_MAKE`: how many processes should be used when compiling. The default is the number of CPUs (e.g. `-j 7`).
- `MACHINE`: the machine the target is built for, e.g. `imx8mp-icore`.

---
layout: default
---

::title::

Let's start to build our image

::body::

What is needed? Suppose that we have a project that we'd like to build. The easiest target is something already in the Yocto poky project, e.g. an emulation target.

```bash
source poky/oe-init-build-env
bitbake core-image-minimal
```

```text
bitbake core-image-minimal
Loading cache: 100% |############################################| ETA:  --:--:--
---
Build Configuration:
BB_VERSION           = "2.18.0"
BUILD_SYS            = "x86_64-linux"
NATIVELSBSTRING      = "ubuntu-24.04"
TARGET_SYS           = "x86_64-poky-linux"
MACHINE              = "qemux86-64"
DISTRO               = "poky"
DISTRO_VERSION       = "6.0.4"
TUNE_FEATURES        = "m64 core2"
TARGET_FPU           = ""
meta
meta-poky
meta-yocto-bsp       = "wrynose:79b6d87030178bed0088ad3b00aa6dfbabac37c4"
```

---
layout: default
---

::title::

Let's set up our environment on local machine

::body::

```bash
sudo apt install gawk wget git diffstat unzip texinfo gcc build-essential \
  chrpath socat cpio python3 python3-pip python3-pexpect xz-utils \
  debianutils iputils-ping python3-git python3-jinja2 libegl1-mesa \
  libsdl2-dev python3-subunit mesa-common-dev zstd liblz4-tool file locales
sudo locale-gen en_US.UTF-8
```

Those packages are used for building a real platform.

```bash
git clone -b wrynose https://git.yoctoproject.org/git/poky
. ./poky/oe-init-build-env
bitbake core-image-full-cmdline
```

---
layout: default
---

::title::

Let's run our build

::body::

```bash
runqemu qemux86-64 core-image-full-cmdline
```

The command, after prompting for the root password, will run a QEMU instance in a window and allow it to operate in a QEMU-KVM execution environment.

---
layout: default
---

::title::

Let's start with more topics

::body::

- Learn the syntax (variables and operators)
- Select package variants. What version of the software would we like to include in our builds?
- Add packages manually to the generated images.
- How to use BitBake to run specific tasks.

---
layout: default
---

::title::

Let's do some recap

::body::

- A recipe describes how to fetch, configure, compile and install a component (application, library, …).
- These tasks can be run independently (if their dependencies are met).
- All the available packages in the project layer are not selected by default to be built and included in the images.
- Some packages may provide the same functionality, e.g. SSH and Dropbear.
