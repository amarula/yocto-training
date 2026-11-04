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
- Don't apply any change to OE-Core or any layer that is used by you.
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
source openembedded-core/oe-init-build-env [builddir] [bitbakedir]
```

For an OE-Core checkout next to BitBake:

```bash
source openembedded-core/oe-init-build-env build bitbake
```

After the file is sourced, you'll land in `[builddir]`. The build directory already contains the basic OpenEmbedded structure. If the build directory is missing, the default build directory is created.

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
- `DISTRO`: the distribution policy. With OE-Core it defaults to `nodistro`; a product normally selects a custom distro layer.

---
layout: default
---

::title::

Let's start to build our image

::body::

What is needed? Suppose that we have a project that we'd like to build. The easiest target is something already in OE-Core, e.g. an emulation target.

```bash
git clone https://git.openembedded.org/bitbake
git clone -b wrynose https://git.openembedded.org/openembedded-core
source openembedded-core/oe-init-build-env build bitbake
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
TARGET_SYS           = "x86_64-oe-linux"
MACHINE              = "qemux86-64"
DISTRO               = "nodistro"
DISTRO_VERSION       = "nodistro.0"
TUNE_FEATURES        = "m64 core2"
TARGET_FPU           = ""
meta                 = "wrynose:ae5a301091f5b0574ea7444aab40b309b6d9f3f2"
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

Those packages are used for building a real platform. Alternatively, `kas-container` can provide a controlled build environment.

The hands-on project lives in `labs/` in the training repository. The `kas.sh` wrapper keeps repository checkouts in `labs/work/` and the build in `labs/build/`. See `labs/README.md` for the lab index.

```bash
pipx install kas
cd labs
./kas.sh build kas/qemu.yml
```

The KAS chapter later explains the configuration file in detail.

---
layout: default
---

::title::

Hands-on labs

::body::

The training repository contains a working lab project under `labs/`:

```text
labs/
├── kas/qemu.yml          # QEMU build
├── kas/imx8mp.yml        # i.MX8M Plus board build
├── meta-training/        # training layer
├── labs/                 # step-by-step exercises
└── scripts/check-lab.sh  # validation
```

- `./kas.sh build kas/qemu.yml` builds `training-image`
- `./kas.sh shell kas/qemu.yml -c 'runqemu qemux86-64 training-image'` boots it
- `labs/00-setup.md`, `labs/01-build-and-run.md` and `labs/02-inspect-build.md` are the first exercises
- `./scripts/check-lab.sh` validates the result

---
layout: default
---

::title::

Let's run our build

::body::

From the manual build directory:

```bash
runqemu qemux86-64 core-image-full-cmdline
```

With KAS:

```bash
kas shell kas/yocto-training.yml -c 'runqemu qemux86-64 core-image-full-cmdline'
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
