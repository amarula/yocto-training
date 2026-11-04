---
layout: center
class: text-center
---

# Yocto

## Layers

---
layout: default
---

::title::

Yocto layers

::body::

- The OpenEmbedded build system manipulates metadata.
- Layers allow isolating and organizing the metadata.
  - A layer is a collection of recipes.
- It is good practice to begin a layer name with the prefix `meta-`.

We think of layers as a stack of parts that we want to use in order to compose our board support package. The suggestion is to use official layers and "never" change maintained layers with specific changes.

---
layout: default
---

::title::

Yocto layers

::body::

<div class="flex flex-col gap-3 max-w-xl mx-auto mt-6 text-center text-xl font-semibold">
  <div class="border-2 border-accent rounded p-4">USEFUL LAYERS</div>
  <div class="border-2 border-accent rounded p-4">LAYERS HARDWARE VENDOR</div>
  <div class="border-2 border-accent rounded p-4">OPENEMBEDDED-CORE</div>
  <div class="border-2 border-accent rounded p-4">BSP LAYER</div>
</div>

---
layout: default
---

::title::

Yocto OpenEmbedded-Core layers

::body::

OE-Core contains the core layers:

- `meta`
- `meta-selftest`
- `meta-skeleton`

Additional layers such as `meta-openembedded`, BSP layers and distro layers are separate repositories.

---
layout: default
---

::title::

Yocto layers from 3rd party

::body::

Common layers are not enough to create a full complete BSP. Users need graphics toolkits, software update features, specific hardware or architecture support. We need to use third-party layers.

Examples:

- `meta-qt6`
- `meta-freescale`
- `meta-ti`
- `meta-rockchip`
- `meta-arm`
- `meta-rauc`
- `meta-swupdate`

Where can I find them? [https://layers.openembedded.org](https://layers.openembedded.org)

---
layout: default
---

::title::

Yocto layers create vs use

::body::

- Avoid developing layers when they already exist.
- Downloading takes less time than writing code.
- If a layer needs to be fixed, upstream your change to the mailing list.
- If you have a specific change to some recipes, create the `.bbappend` file for it.
- Class files do not use layer priority, so if you need to change a class file, you mostly need to fork it.

---
layout: default
---

::title::

Yocto layers how use them?

::body::

- The location where a layer is saved on disk doesn't matter (almost).
  - But a good practice is to save it where all other layers are stored.
- The only requirement is to let BitBake know about the new layer:
  - The list of layers BitBake uses is defined in `$BUILDDIR/conf/bblayers.conf`.
  - To include a new layer, add its absolute path to the `BBLAYERS` variable.
  - BitBake parses each layer specified in `BBLAYERS` and adds the recipes, configuration files and classes it contains.

---
layout: default
---

::title::

Yocto useful layers

::body::

As I mentioned, many SoCs use their specific layer (NXP, TI, Rockchip), and some of them provide relevant tools or packages that are used in many distributions:

- `meta-swupdate` and `meta-rauc`, as I have already mentioned
- `meta-openembedded` (meta-oe, meta-python, meta-networking, meta-multimedia)
- `meta-arm`
- `meta-security`
- `meta-virtualization`
- `meta-browser`
- `meta-qt6`

We always need matching between the Yocto version and layer compatibility.

---
layout: default
---

::title::

Yocto A simple layer (1 / 3)

::body::

```text
# We have a conf and classes directory, add to BBPATH
BBPATH .= ":${LAYERDIR}"

# We have recipes-* directories, add to BBFILES
BBFILES += "${LAYERDIR}/recipes-*/*/*.bb \
            ${LAYERDIR}/recipes-*/*/*.bbappend"

BBFILE_COLLECTIONS += "meta-w_and_h"
BBFILE_PATTERN_meta-w_and_h = "^${LAYERDIR}/"
BBFILE_PRIORITY_meta-w_and_h = "6"
LAYERDEPENDS_meta-w_and_h = "core openembedded-layer"
LAYERSERIES_COMPAT_meta-w_and_h = "wrynose"
```

---
layout: default
---

::title::

Yocto A simple layer (2 / 3)

::body::

- `BBPATH` adds the layer's root directory to BitBake's search path.
- `BBFILES` defines the location for all recipes in the layer.
- `BBFILE_COLLECTIONS` establishes the current layer through a unique identifier that is used throughout the OpenEmbedded build system to refer to the layer.
- `BBFILE_PATTERN_<layer_name>` expands immediately during parsing to provide the directory of the layer.
- `BBFILE_PRIORITY_<layer_name>` establishes a priority to use for recipes in the layer.
- `LAYERDEPENDS_<layer_name> = "layer1 layer2"` lists all layers on which this layer depends (if any).
- `LAYERSERIES_COMPAT_<layer_name> = "wrynose"` lists the Yocto Project releases for which the current version is compatible.

---
layout: default
---

::title::

Yocto A simple layer (3 / 3)

::body::

```text
tree -L 1
.
├── conf
├── COPYING.MIT
├── README
└── recipes-example
```

This is a dummy layer created using the `bitbake-layers create-layer` command.

Is that so easy?

---
layout: default
---

::title::

Yocto layers how use them?

::body::

We talked about absolute paths. Is that really so? It's easier than you expect:

```text
BBPATH = "${TOPDIR}"
BSPDIR := "${@os.path.abspath(os.path.dirname(d.getVar('FILE', True)) + '/../..')}"

BBFILES ?= ""

BBLAYERS = " \
  ${BSPDIR}/sources/openembedded-core/meta \
  \
  ${BSPDIR}/sources/meta-openembedded/meta-oe \
  ${BSPDIR}/sources/meta-openembedded/meta-multimedia \
  ${BSPDIR}/sources/meta-openembedded/meta-python \
  ${BSPDIR}/sources/meta-openembedded/meta-networking \
  \
  ${BSPDIR}/sources/meta-freescale \
  ${BSPDIR}/sources/meta-freescale-3rdparty \
  ${BSPDIR}/sources/meta-freescale-distro \
  ${BSPDIR}/sources/meta-qt6 \
"
```

It uses a trick to derive the source directory from the location of `bblayers.conf`. `BBPATH` tells BitBake where to find configuration files.

---
layout: default
---

::title::

Yocto layers how use them?

::body::

- The `bitbake-layers` tool is provided alongside BitBake.
- It can be used to inspect the layers and to manage `$BUILDDIR/conf/bblayers.conf`:
  - `bitbake-layers show-layers`
  - `bitbake-layers add-layer meta-custom`
  - `bitbake-layers remove-layer meta-qt5`

---
layout: default
---

::title::

Yocto Board support package layer

::body::

- A layer provides one machine file (hardware configuration file) per machine it supports.
- These configuration files are stored under `meta-w_and_h/conf/machine/imx8mp-icore-ctouch2-of10.conf`.
- The file names correspond to the values set in the `MACHINE` configuration variable.
  - `meta-w_and_h/conf/machine/imx8mp-icore-ctouch2-of10.conf`
  - `MACHINE = "imx8mp-icore-ctouch2-of10"`
- Each machine should be described in the README file of the BSP.

---
layout: default
---

::title::

Yocto Distro layers

::body::

- You can create a new distribution by using a distro layer.
- This allows changing the defaults that are provided by openembedded-core.
- It is useful to distribute changes that have been made in `local.conf`.

---
layout: default
---

::title::

Yocto Distro layers best practices

::body::

- A distro layer is used to provide policy configurations for a custom distribution.
- It is a best practice to separate the distro layer from the custom layers you may create and use.
- It often contains:
  - Configuration files.
  - Specific classes.
  - Distribution-specific recipes: initialization scripts, splash screen…
