---
layout: default
---

::title::

Why KAS

::body::

- A product build is not a single git repository: OE-Core, BitBake, meta-openembedded, BSP layers and your own layers must all match.
- KAS describes the whole project in one YAML or JSON file: machine, distro, target, repositories and layers.
- It fetches the repositories, generates `local.conf` and `bblayers.conf`, and runs BitBake.
- The same file works on a developer machine, in a container and in CI.
- It supports includes, layer priorities, lockfiles and release pinning.

---
layout: default
---

::title::

Install KAS

::body::

- Install from PyPI with `pipx` (or `pip`):

```bash
pipx install kas
kas --version
```

- Or run it in the official container, without installing host dependencies:

```bash
kas-container --version
kas-container build kas/yocto-training.yml
```

- The container image is `ghcr.io/siemens/kas/kas:<version>`; this course uses KAS 5.5.
- KAS does not replace BitBake; it prepares the environment and invokes it.

---
layout: default
---

::title::

KAS project layout

::body::

```text
yocto-training-project/
├── kas/
│   ├── base.yml
│   ├── bsp-imx8mp.yml
│   └── yocto-training.yml
└── layers/
    └── meta-w_and_h/
```

- `base.yml` contains the common repositories and policy.
- `bsp-imx8mp.yml` adds the BSP layer and machine settings.
- `yocto-training.yml` includes both and sets the product target:

```yaml
header:
  version: 23
  includes:
    - base.yml
    - bsp-imx8mp.yml
```

- Includes can also come from another repository:

```yaml
header:
  version: 23
  includes:
    - repo: meta-w_and_h
      file: kas/bsp.yml
```

---
layout: default
---

::title::

A minimal KAS configuration

::body::

```yaml
header:
  version: 23

machine: qemux86-64
distro: nodistro
target: core-image-minimal

repos:
  bitbake:
    url: https://git.openembedded.org/bitbake
    branch: 2.18
    layers: {}

  core:
    url: https://git.openembedded.org/openembedded-core
    branch: wrynose
    layers:
      meta:
```

- `header.version` selects the KAS configuration format (23 for KAS 5.5).
- `bitbake` provides the build engine and no layer.
- `core` is OE-Core; the `meta` layer is added to `bblayers.conf`.
- `distro: nodistro` uses OE-Core's default policy.

---
layout: default
---

::title::

Adding layers and a BSP

::body::

```yaml
repos:
  meta-openembedded:
    url: https://github.com/openembedded/meta-openembedded.git
    branch: wrynose
    layers:
      meta-oe:
      meta-python:
      meta-networking:
      meta-multimedia:

  meta-arm:
    url: https://git.yoctoproject.org/meta-arm
    branch: wrynose
    layers:
      meta-arm:
      meta-arm-bsp:
      meta-arm-toolchain:

  meta-w_and_h:
    path: layers/meta-w_and_h
    layers:
      meta-w_and_h:
```

- `path` is used for a local layer that is part of the project.
- Only the layers listed under `layers` are added to `BBLAYERS`.
- `prio` can control the order in which layers are added (KAS format 21+).

---
layout: default
---

::title::

Generated configuration

::body::

```yaml
bblayers_conf_header:
  training: |
    LCONF_VERSION = "7"
    BBPATH = "${TOPDIR}"
    BBFILES ?= ""

local_conf_header:
  training: |
    CONF_VERSION = "2"
    PACKAGE_CLASSES = "package_ipk"
    EXTRA_IMAGE_FEATURES = "debug-tweaks"
    PREFERRED_PROVIDER_virtual/kernel = "linux-imx"
```

- KAS writes these blocks to `build/conf/bblayers.conf` and `build/conf/local.conf`.
- `LCONF_VERSION` and `CONF_VERSION` must match the OE-Core templates (7 and 2 for 6.0).
- Inspect the result with `kas shell` or `kas dump`.

---
layout: default
---

::title::

KAS commands

::body::

- `kas build <config>`: fetch, configure and build the target.
- `kas shell <config>`: open a shell in the generated build environment.
- `kas shell <config> -c 'bitbake <target>'`: run a single BitBake command.
- `kas checkout <config>`: fetch repositories and generate the configuration without building.
- `kas lock <config>`: create or update the lockfile with exact commits.
- `kas dump <config>`: print the resolved configuration.

```bash
kas build kas/yocto-training.yml
kas shell kas/yocto-training.yml -c 'bitbake -c listtasks virtual/kernel'
```

---
layout: default
---

::title::

Reproducibility and lockfiles

::body::

- `branch` alone is floating; a release must pin every repository.
- Use `tag` or `commit` in the configuration:

```yaml
repos:
  core:
    url: https://git.openembedded.org/openembedded-core
    tag: yocto-6.0.4
    commit: 0f03c732a0a2d0506b41b1abe60b3f368b2300dc
  bitbake:
    url: https://git.openembedded.org/bitbake
    tag: yocto-6.0.4
    commit: 51fd94a67fa17650a9ff623492005972bbc7d26f
```

- `refspec` is deprecated since KAS format 14; use `branch`, `tag` or `commit`.
- `kas lock` writes a `*.lock.yml` file with the exact commit of every repository.
- Commit the lockfile and tag it together with the project for a product release.

---
layout: default
---

::title::

Container and CI

::body::

- `kas-container` runs KAS and BitBake in the official container:

```bash
kas-container build kas/yocto-training.yml
kas-container shell kas/yocto-training.yml -c 'bitbake core-image-minimal'
```

- Select a container version with `KAS_IMAGE_VERSION`:

```bash
KAS_IMAGE_VERSION=5.5 kas-container build kas/yocto-training.yml
```

- Example GitLab CI job:

```yaml
build:
  image: ghcr.io/siemens/kas/kas:5.5
  script:
    - kas build kas/yocto-training.yml
```

- The container pins host tools, so builds are reproducible across developers and CI runners.

---
layout: default
---

::title::

KAS and bitbake-setup

::body::

- Upstream Yocto provides `bitbake-setup` for setting up a build from a JSON/YAML configuration.
- It is a good fit for simple builds and for working with local sources (`--use-local-source`).
- KAS adds multi-repository layering, includes, layer priorities, lockfiles, container integration and CI-friendly releases.
- For a product with several layers and a tagged release, KAS is the more complete project tool.
- For the training project we use KAS; the concepts transfer directly to other setup tools.

---
layout: default
---

::title::

Checkpoint: KAS

::body::

1. What does `header.version` describe?
2. Why should a release pin `tag` or `commit` instead of only `branch`?
3. What does `kas lock` produce, and why is it committed?
4. How do you run a single BitBake command inside the KAS environment?
