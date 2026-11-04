---
layout: center
class: text-center
---

# Yocto

## Build Internals and Performance

---
layout: default
---

::title::

Build anatomy

::body::

- Parse metadata: BitBake reads layers, recipes, classes and configuration.
- Fetch sources into `DL_DIR`.
- Unpack, patch, configure, compile and install into the work directory.
- Package the installed files.
- Build the root filesystem and the image.
- Shared state (sstate) caches task outputs so unchanged tasks are reused.
- Inspect the task graph with `bitbake -g` and `taskexp`.

---
layout: default
---

::title::

Shared state (sstate)

::body::

- Shared state is a cache of task outputs keyed by task signatures.
- `SSTATE_DIR` defaults to `${TOPDIR}/sstate-cache`.
- A rebuild reuses sstate when inputs, configuration and toolchain are unchanged.
- sstate files are `.tar.zst` plus signature and tracking files.
- `bitbake -S printdiff <target>` explains why a task is not reused.
- First build: everything is built. Later builds: mostly sstate.

---
layout: default
---

::title::

Hash equivalence

::body::

- OE-Core 6.0 defaults:

```text
BB_SIGNATURE_HANDLER = "OEEquivHash"
BB_HASHSERVE = "auto"
```

- Hash equivalence maps different task signatures that produce the same output.
- `BB_HASHSERVE_DB_DIR` stores the equivalence database.
- It improves sstate reuse across machines, configurations and CI.
- `bitbake -S printdiff` shows the signature differences.
- Keep the hash server database with the sstate cache.

---
layout: default
---

::title::

Sharing sstate and downloads

::body::

- Share `SSTATE_DIR` between builds and CI.
- `SSTATE_MIRRORS` adds read-only remote caches:

```text
SSTATE_MIRRORS ?= "file://.* file:///srv/sstate/PATH"
```

- `DL_DIR` caches downloads; `PREMIRRORS` and `MIRRORS` add source mirrors.
- `BB_GENERATE_MIRROR_TARBALLS = "1"` creates tarballs for source mirrors.
- `BB_NO_NETWORK = "1"` validates an offline build.
- Cache both `DL_DIR` and `SSTATE_DIR` in CI for fast, repeatable builds.

---
layout: default
---

::title::

Build performance

::body::

- `BB_NUMBER_THREADS` — parallel BitBake tasks.
- `PARALLEL_MAKE` — parallel make jobs.
- Fast local storage and enough RAM often matter more than CPU alone.
- Keep `SSTATE_DIR` on fast storage and share `DL_DIR`.
- `ccache` (`CCACHE_DIR`, `CCACHE_TOP_DIR`) can speed up recompiles.
- `INHERIT += "rm_work"` reduces disk usage.
- Hash equivalence avoids redundant work across configurations.

---
layout: default
---

::title::

Saving disk with rm_work

::body::

```text
INHERIT += "rm_work"
RM_WORK_EXCLUDE += "hello"
RM_WORK_EXCLUDE_ITEMS = "temp"
```

- Removes work directories after the build.
- `RM_WORK_EXCLUDE` keeps selected recipes.
- `RM_WORK_EXCLUDE_ITEMS` keeps selected items (default `temp`).
- Saves tens of gigabytes on large builds.
- Do not enable it on a machine you are actively debugging.

---
layout: default
---

::title::

Tracking changes with buildhistory

::body::

```text
INHERIT += "buildhistory"
BUILDHISTORY_COMMIT = "1"
BUILDHISTORY_FEATURES = "image package sdk"
```

- Records image, package and SDK contents in a git repository under `buildhistory/`.
- `buildhistory-diff` shows changes between builds.
- `BUILDHISTORY_PUSH_REPO` pushes the history to a remote repository.
- Review package upgrades, image size and file changes.
- `BUILDHISTORY_IMAGE_FILES` adds files to the recorded image data.

---
layout: default
---

::title::

PACKAGECONFIG

::body::

```text
PACKAGECONFIG ??= "foo"
PACKAGECONFIG[foo] = "--enable-foo,--disable-foo,libfoo,libfoo-runtime"
PACKAGECONFIG:append:pn-<recipe> = " bar"
```

- Four fields: enable option, disable option, build dependencies, runtime dependencies.
- Recipes use it to expose optional features (systemd, x11, wayland, ssl, …).
- Inspect the effective value:

```bash
bitbake -e <recipe> | grep ^PACKAGECONFIG=
```

- Prefer `PACKAGECONFIG` over editing a recipe for optional features.

---
layout: default
---

::title::

DISTRO_FEATURES

::body::

- Distribution policy, not hardware.
- Examples: `systemd`, `x11`, `wayland`, `pam`, `ipv6`, `seccomp`.
- Inspect the effective value:

```bash
bitbake -e | grep ^DISTRO_FEATURES=
```

- OE-Core 6.0:
  - `DISTRO_FEATURES_DEFAULTS` lists the default features.
  - `DISTRO_FEATURES_OPTED_OUT` removes a default.
- Change in a distro layer:

```text
DISTRO_FEATURES:append = " systemd"
DISTRO_FEATURES:remove = " x11"
```

---
layout: default
---

::title::

MACHINE_FEATURES

::body::

- Hardware capabilities exposed by the machine:

```text
MACHINE_FEATURES = "usbhost usbgadget wifi bluetooth rtc"
```

- Used by recipes and images to select hardware support.
- `MACHINE_EXTRA_RRECOMMENDS` adds machine-specific packages.
- `DISTRO_EXTRA_RDEPENDS` and `DISTRO_EXTRA_RRECOMMENDS` add distro packages.
- Inspect:

```bash
bitbake -e | grep -E '^(MACHINE_FEATURES|DISTRO_FEATURES)='
```

---
layout: default
---

::title::

Tuning and optimization

::body::

- `DEFAULTTUNE` selects the CPU tune, e.g. `cortexa53-crypto`.
- `TUNE_FEATURES` is derived from the tune.
- `PACKAGE_ARCH` and `MACHINE_ARCH` affect package compatibility.
- Optimization:
  - `FULL_OPTIMIZATION` for release builds
  - `DEBUG_BUILD = "1"` selects `DEBUG_OPTIMIZATION` (`-Og -g`)
  - `SELECTED_OPTIMIZATION` is the effective set
- `IMAGE_FEATURES += "dbg-pkgs dev-pkgs"` adds debug symbols and headers.

---
layout: default
---

::title::

Disk space and cleanup

::body::

- Monitor disk space:

```text
BB_DISKMON_DIRS = "STOPTASKS,${TMPDIR},1G,100K WARN,${SSTATE_DIR},1G,100K"
BB_DISKMON_WARNINTERVAL = "50M,5K"
```

- Inspect usage:

```bash
du -sh build/tmp build/sstate-cache build/downloads
```

- Clean:
  - `bitbake -c clean <recipe>`
  - `bitbake -c cleansstate <recipe>`
  - `bitbake -c cleanall <recipe>`
- Manage sstate:

```bash
scripts/sstate-cache-management.py --cache-dir build/sstate-cache -n
```

Remove `-n` to apply the changes.

---
layout: default
---

::title::

Towards reproducible builds

::body::

- Pin inputs: `SRCREV`, tags, lockfiles and layer revisions.
- `SOURCE_DATE_EPOCH` controls timestamps in archives and images.
- `SOURCE_DATE_EPOCH_FALLBACK` is used when no value is set.
- `DEBUG_PREFIX_MAP` strips build paths from debug information; the `buildpaths` QA check enforces it.
- Avoid host paths, hostnames and timestamps in generated files.
- Use `buildhistory` and compare images between builds.
- Full reproducibility is a process, not a single variable.

---
layout: default
---

::title::

Hands-on lab: build internals

::body::

- Lab: `labs/exercises/12-build-internals.md`
- Measure disk usage:

```bash
du -sh build/tmp build/sstate-cache build/downloads
```

- Enable `rm_work` and compare the disk usage.
- Enable `buildhistory` and run `buildhistory-diff`.
- Inspect feature switches:

```bash
bitbake -e <recipe> | grep ^PACKAGECONFIG=
bitbake -e | grep -E '^(DISTRO_FEATURES|MACHINE_FEATURES)='
```

- Check sstate and signatures:

```bash
bitbake -S printdiff training-image
```

- Challenge: change one `DISTRO_FEATURES` entry and measure the rebuild.

---
layout: default
---

::title::

Checkpoint: build internals

::body::

1. What is shared state, and what invalidates it?
2. What do `BB_NUMBER_THREADS` and `PARALLEL_MAKE` control?
3. What does `rm_work` remove, and how do you exclude a recipe?
4. What is `PACKAGECONFIG` used for?
5. What is the difference between `DISTRO_FEATURES` and `MACHINE_FEATURES`?
6. How do you inspect sstate cache usage and clean it safely?
