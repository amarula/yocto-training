---
layout: center
class: text-center
---

# Yocto

## Recipes

---
layout: default
---

::title::

Yocto recipes

::body::

Let's start with a simple example and start from there:

```text
SUMMARY = "Poky-tiny init"
DESCRIPTION = "Basic init system for poky-tiny"
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${COREBASE}/meta/COPYING.MIT;md5=3da9cfbcb788c80a0384361b4de20420"
PR = "r2"
RDEPENDS:${PN} = "busybox"
SRC_URI = "file://init \
           file://rc.local.sample \
          "
S = "${WORKDIR}"

do_configure() {
    :
}

do_compile() {
    :
}

do_install() {
    install -d ${D}${sysconfdir}
    install -m 0755 ${WORKDIR}/init ${D}
    install -m 0755 ${WORKDIR}/rc.local.sample ${D}${sysconfdir}
}

FILES:${PN} = "/init ${sysconfdir}/rc.local.sample"
RCONFLICTS:${PN} = "systemd"
```

---
layout: default
---

::title::

Yocto recipes

::body::

- `SUMMARY`: short description of the recipe.
- `DESCRIPTION`: describes what this package is doing or is supposed to implement.
- `LICENSE`: declares the package license. This is really important to have because it is used for license compliance when we need to release a product on the market.
- `LIC_FILES_CHKSUM`: defines the license checksum using a URI form.
- `PR`: represents the revision of the recipe. Default value is "r0". Subsequent revisions conventionally use "r1", "r2" and so on.
- `SRC_URI`: is where to download code. This can refer even to a local directory, as in this case, and local files.
- `S`: is where the source code should be downloaded.

---
layout: default
---

::title::

Yocto recipes

::body::

As we can see, a simple recipe already contains a number of elements that for most of you are new. Don't be scared; all of them repeat the same structure.

We have already talked about tasks. The example above just defines:

- `do_configure`
- `do_compile`
- `do_install`

`FILES` helps Yocto figure out which files are needed for the installation task.

`RCONFLICTS` just explains that there is a conflict with systemd, which in turn interacts with the same components.

---
layout: default
---

::title::

Yocto recipe structure

::body::

Firstly, it's a text file, nothing more. The file extension is `.bb` for newly created recipes, and `.bbappend` if you want to override an already defined recipe. Really easy, isn't it?

All the recipes are under a layer. Recipes are organized under directories, and the name of the directory is part of the Yocto structure. So expect to have gstreamer under `meta-multimedia`.

---
layout: default
---

::title::

Yocto recipe structure (re-take again)

::body::

- A recipe describes how to handle a given software component (application, library, …).
- It is a set of instructions describing how to retrieve, patch, compile, install and generate binary packages.
- It also defines what build or runtime dependencies are required.
- Recipes are parsed by the BitBake build engine.
- The format of a recipe file name is `<application-name>_<version>.bb`.

---
layout: default
---

::title::

Yocto recipe content

::body::

- A recipe contains configuration variables: name, license, dependencies, path to retrieve source code.
- It also contains functions that can be run (fetch, configure, compile…) which are called tasks.
- Tasks provide a set of actions to perform.
- Remember the `bitbake -c <task> <target>` command?
  - `bitbake -c compile vim`
  - `bitbake vim -c compile`

So what is new compared to what was said at the beginning? The difference is that now we have to actually use them.

---
layout: default
---

::title::

Yocto recipe common variables

::body::

In the example recipe, we already described some variables. Let's look at them again and analyze them deeply:

- Automatically available variables:
  - `PN`: package name, as specified in the recipe file name
  - `BPN`: `PN` with prefixes and suffixes removed, such as `nativesdk-` or `-native`
  - `PV`: package version, as specified in the recipe file name
  - `BP`: defined as `${BPN}-${PV}`
- The recipe name and version usually match the upstream ones.
- Example `llvm-native`:
  - `${BPN}` = "llvm"
  - `${PN}` = "llvm-native"
  - `${PV}` = "13.0.1"

---
layout: default
---

::title::

Yocto recipe organization

::body::

We need to understand how Yocto organizes recipes. What is the problem? Mostly different versions of the same package.

- Many applications have more than one recipe. To support different versions, the common metadata is included in each version-specific recipe and is in a `.inc` file:
  - `<application>.inc`
    - version-agnostic metadata
  - `<application>_<version>.bb`
    - `require <application>.inc`
    - any version-specific metadata
- We can divide a recipe into three main parts:
  - The header: what/who
  - The sources: where
  - The tasks: how

---
layout: default
---

::title::

Yocto recipe source location

::body::

We need to describe how to download the source. We use some form of URI scheme:

- We need to retrieve both the raw sources from an official location and the resources needed to configure, patch or install the application.
- `SRC_URI` defines where and how to retrieve the needed elements. It is a set of URI schemes pointing to resource locations (local and remote).
- URI scheme syntax: `scheme://url;param1;param2`
- The scheme can describe a local file using `file://` or remote locations with `https://`, `git://`, `svn://`, `hg://`, `ftp://`…
- By default, sources are fetched in `$BUILDDIR/downloads`. Change it with the `DL_DIR` variable in `conf/local.conf`.

---
layout: default
---

::title::

Yocto recipe source location

::body::

Let's dive a bit. `FILESPATH` covers even files needed to generate package patches (defined in `meta/classes/base.bbclass`). Consider `FILE_DIRNAME` equal to the recipe directory:

- `FILESPATH` is generated with all combinations of:
- BASE paths:
  - `${FILE_DIRNAME}/${BP}` (e.g. `BP = dropbear-2020.81`)
  - `${FILE_DIRNAME}/${BPN}` (e.g. `BPN = dropbear`)
  - `${FILE_DIRNAME}/files`
  - Items in `FILESEXTRAPATHS` (none by default)
  - `${FILE_DIRNAME}` is the directory containing the `.bb` file
- The overrides in `FILESOVERRIDES`:
  - Set as `${TRANSLATED_TARGET_ARCH}:${MACHINEOVERRIDES}:${DISTROOVERRIDES}`
  - E.g. `arm:armv7a:ti-soc:ti33x:beaglebone:poky`
  - Applied right to left

---
layout: default
---

::title::

Yocto recipe uri scheme by example

::body::

```text
SRC_URI = "https://mesa.freedesktop.org/archive/demos/${BPN}-${PV}.tar.bz2"
SRC_URI = "git://github.com/google/shaderc.git;protocol=https;branch=main"
SRC_URI = "file://pointercal.xinput"
SRC_URI += "https://cdn.kernel.org/pub/linux/kernel/v4.x/linux-4.0.9.tar.xz \
            file://kernelpatch.scc \
            file://kernel-4.0.9.cfg \
           "
```

More examples can be found just using `git grep` under poky and looking for `SRC_URI`.

---
layout: default
---

::title::

Yocto recipe uri scheme authentication

::body::

`SRC_URI` can mostly download from any kind of source, including private repositories. How do we handle authentication in this case?

- `.git-credentials`
- `.netrc`

Both methods allow you to download from private repositories and handle transparent authentication to your provider. You need an ssh-agent running, but it's mostly provided by any distribution by default.

---
layout: default
---

::title::

Yocto recipe uri scheme file integrity

::body::

We need to be sure that the package we download is what we expect. How can this be managed?

- An md5 or sha256 sum must be provided when the protocol used to retrieve the file(s) does not guarantee their integrity. This is the case for https, http or ftp.
- It's possible to use checksums for more than one file, using the `name` parameter:

```text
SRC_URI = "http://example.com/src.tar.bz2;name=tarball \
           http://example.com/fixes.patch;name=patch"
SRC_URI[tarball.md5sum] = "97b2c3fb082241ab5c56..."
SRC_URI[patch.md5sum] = "b184acf9eb39df794ffd..."
```

---
layout: default
---

::title::

Yocto recipe uri for local file

::body::

- `SRC_URI` can handle local files.
- They are not downloaded but copied to the work directory.
- `FILESPATH` is the variable used to find files that need to be copied.
- `FILESPATH` is a colon-separated list of paths in which to look for files.
- The order matters: when a file is found in a path, the search ends.

---
layout: default
---

::title::

Yocto recipe uri for local file

::body::

How to get the `FILESPATH` of a package? Think easy:

```bash
bitbake -e dropbear | grep ^FILESPATH=
bitbake -e go | grep ^FILESPATH=
```

Those commands can be run after sourcing the environment.

`-e` is used for:

Show the global or per-recipe environment complete with information about where variables were set/changed.

---
layout: default
---

::title::

Yocto recipe uri for local file

::body::

How is `FILESPATH` used? Why are we talking about it?

As I mentioned, the recipe needs to find the files that are sometimes what you need to install in the target filesystem or the patch of a specific package; anyway, everything that needs to be copied into the work directory.

- This complex logic allows using different files without conditionals.
- Example with a single item in `SRC_URI`:
  - `SRC_URI += "file://defconfig"`

`SRC_URI` allows us to have different defconfig on different `MACHINE`. We will explain these concepts better when we talk about `OVERRIDES`.

---
layout: default
---

::title::

Yocto recipe source tarballs

::body::

- When extracting a tarball, BitBake expects to find the extracted files in a directory named `<application>-<version>`. This is controlled by the `S` variable.
- If the scheme is git, `S` must be set to `${WORKDIR}/git`.

Let's try an example:

```text
bitbake gdb -> what are you expecting from this command?
bitbake -c devshell gdb -> what are you expecting from this command?
```

The workdir of this command is: `build/tmp/work/core2-64-poky-linux/gdb/11.2-r0/gdb-11.2`

---
layout: default
---

::title::

Yocto recipe dependencies

::body::

We already discussed the concept of dependencies. How can those be mapped to Yocto syntax?

- `DEPENDS`: package build dependencies
- `RDEPENDS`: package runtime dependencies

Let's see an example:

- `DEPENDS = "recipe-b"`: the local `do_prepare_recipe_sysroot` task depends on the `do_populate_sysroot` task of `recipe-b`.
  - `gdb DEPENDS = "expat gmp zlib ncurses virtual/libiconv ${LTTNGUST} bison-native"`
- `RDEPENDS:${PN} = "package-b"`: the local `do_build` task depends on the `do_package_write_<archive-format>` task of recipe b.
  - `consolekit RDEPENDS:${PN} += "base-files"`

---
layout: default
---

::title::

Yocto recipe dependencies

::body::

- Sometimes a recipe has dependencies on specific versions of another recipe.
- BitBake allows this by using:
  - `DEPENDS = "recipe-b (>= 1.2)"`
  - `RDEPENDS:${PN} = "recipe-b (>= 1.2)"`
- The following operators are supported: `=`, `>`, `<`, `>=` and `<=`.

`DEPENDS` can have matching rules like in the following example:

```text
DEPENDS:append:x86-64:class-target = " nasm-native"
```

This means that when you build the recipe for x86-64 for the target, then `nasm-native` is added to `DEPENDS`. It's just a specific `DEPENDS` that needs to be applied on x86-64 to build an assembler on the target.

---
layout: default
---

::title::

Yocto recipe dependencies

::body::

Sometimes it is useful to graph dependencies:

- `bitbake -g <package name>`
- `dot -Tsvg task-depends.dot -o package.svg` (this process seems now very slow on latest Ubuntu)
- `bitbake -g -u taskexp core-image-minimal`

---
layout: default
---

::title::

Yocto recipe organization. Let's dive in it

::body::

```text
tree -L 1
.
├── files
├── libglu_9.0.2.bb
├── mesa_22.0.3.bb
├── mesa-demos
├── mesa-demos_8.4.0.bb
├── mesa-gl_22.0.3.bb
└── mesa.inc
```

We have everything here: the `mesa.inc` and the recipes.

The `files` directory usually includes files to be installed or patches to be applied.

`mesa-gl_22.0.3.bb`: `require mesa.inc`

---
layout: default
---

::title::

Yocto recipe organization in block

::body::

| Layer | Recipe | Result |
| --- | --- | --- |
| Higher priority | `package_1.2` | selected |
| Lower priority | `package_1.3` | ignored |

The recipe in the highest-priority layer will be used even if the recipe version in that layer is lower, so version numbers should only matter if the layer priorities are the same. In the picture above, the recipe `package_1.2` is selected because the layer has higher priority. The priority is not valid for class files, but they follow inclusion priority. The same happens for `bblayers.conf`, where with the same priority the order wins.

---
layout: default
---

::title::

Yocto recipe organization in block

::body::

How to find the recipes?

```bash
find -name '*gdb*bb*'
./meta/recipes-kernel/wireless-regdb/wireless-regdb_2023.02.13.bb
./meta/recipes-support/gdbm/gdbm_1.23.bb
./meta/recipes-devtools/gdb/gdb_11.2.bb
./meta/recipes-devtools/gdb/gdb-cross-canadian_11.2.bb
./meta/recipes-devtools/gdb/gdb-cross_11.2.bb
```

Or nicer and better, using tools that support regular expressions:

```text
bitbake-layers show-recipes 'gdb*'
=== Matching recipes: ===
gdb:
  meta             11.2
gdb-cross-canadian-x86-64:
  meta             11.2
gdb-cross-x86_64:
  meta             11.2
gdbm:
  meta             1.23
```

---
layout: default
---

::title::

Yocto recipe patches (1 / 4)

::body::

Patches can be applied to resolve build-system problems:

- To support old versions of software: bug and security fixes.
- To fix cross-compilation issues.
  - In certain simple cases, the `-e` option of `make` can be used.
  - The `-e` option gives variables taken from the environment precedence over variables from Makefiles.
  - Helps when an upstream Makefile uses hardcoded `CC` and/or `CFLAGS`.
- To apply patches before they make their way into the upstream version.

---
layout: default
---

::title::

Yocto recipe patches (2 / 4)

::body::

```text
# Adapted from linux-imx.inc, copyright (C) 2013, 2014 O.S. Systems Software LTDA
# Released under the MIT license (see COPYING.MIT for the terms)
require recipes-kernel/linux/linux-imx.inc
LICENSE = "GPL-2.0-only"
LIC_FILES_CHKSUM = "file://COPYING;md5=6bc538ed5bd9a7fc9398086aedcd7e46"
LINUX_VERSION = "6.4.0"
SRC_URI = "git://git.kernel.org/pub/scm/linux/kernel/git/next/linux-next.git;branch=${SRCBRANCH};protocol=https \
           file://0001-arm64-dts-freescale-Add-Engicam-i.Core-MX8M-Plus-C.T.patch \
           file://0002-dt-bindings-arm-fsl-Add-Engicam-i.Core-MX8M-Plus-C.T.patch \
          "
…
SRCBRANCH = "master"
SRCREV = "44c026a73be8038f03dbdeef028b642880cf1511"
DEPENDS += "lzop-native bc-native"
COMPATIBLE_MACHINE = "(imx8mp-icore-ctouch2-of10)"
..
S = "${WORKDIR}/git"
```

---
layout: default
---

::title::

Yocto recipe patches (3 / 4)

::body::

- Patches are applied in the order that they are defined in `SRC_URI`.
- Patches are applied using the tool defined by `PATCHTOOL`.
- `PATCHTOOL` default is `quilt`.
- `PATCHTOOL` can be changed to `git` to apply patches using git.
- `devtool` creates patches using git.

```text
meta/conf/bitbake.conf: PATCHTOOL = "quilt"
```

`PATCHTOOL` can be overridden in the recipe file:

```text
PATCHTOOL = "git"
```

---
layout: default
---

::title::

Yocto recipe patches (4 / 4)

::body::

- The `PATCHRESOLVE` variable defines how to handle conflicts when applying patches.
- It has two valid values:
  - `noop` -> fail on conflicts
  - `user` -> ask the user to fix it
- By default, `PATCHRESOLVE = "noop"` in `meta-poky`.
