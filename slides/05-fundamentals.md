---
layout: center
class: text-center
---

# Yocto

## Basic components

---
layout: default
---

::title::

Yocto fundamentals: BitBake

::body::

- BitBake is the task executor and scheduler used by the OpenEmbedded build system to build images.
- We can consider `bitbake` as the `make` command in the old-fashioned Makefile.
- BitBake is able to parse and execute recipes and configuration files from the Yocto build system.
- It is written in Python and compatible with Python 3.

Do we need to know how it is coded? For us and during this course, BitBake is just a tool.

---
layout: default
---

::title::

Yocto fundamentals: Recipes

::body::

<div class="grid grid-cols-2 gap-8 items-center">
<div>

- A recipe is just a text file that describes the software components.
- We need to know in recipes how to fetch and build.
- How the software component needs to be installed in the root filesystem.
- The dependencies with other software.
- We need to learn during the course the syntax of a recipe in its fundamental parts.

</div>
<div>

<img src="/images/recipe-flow.png" class="max-h-96 mx-auto" alt="Recipe flow" />

</div>
</div>

---
layout: default
---

::title::

Yocto recipes are small state machine

::body::

- A recipe is composed of several tasks.
- Each task performs a specific step in the build.
- Examples of tasks are: fetch, build, install, package.
- Tasks can depend on other tasks that can be connected to other recipes.
- Example: signing the boot image depends on generating the boot image.

---
layout: default
---

::title::

Yocto fundamentals: Metadata and layers

::body::

- We call "metadata" the input of the BitBake tool.
- As metadata we consider: configuration files, recipes, classes and include files.
- All the metadata are organized in layers. Each layer is a set of recipes, classes, and configuration files.
- A layer can be considered as a group of specialized metadata to support a specific need.
- Example: meta-freescale (implementing Freescale support for Freescale platforms), meta-ti, etc.
- An upper layer can override recipes of lower layers.
- The most important layer is openembedded-core. All the other layers are built on top of it. It supports basic functionalities and architectures such as ARM, x86, RISC-V, etc. (including emulated machines).

---
layout: default
---

::title::

Yocto fundamentals: OpenEmbedded-Core

::body::

- We need a way to organize all the core parts and download them.
- OpenEmbedded-Core (OE-Core) is the metadata layer that contains the core recipes, classes and machine configurations.
- BitBake is a separate repository; together they form the OpenEmbedded build system.
- OE-Core is distro-less: `DISTRO` defaults to `nodistro`, and `MACHINE = "qemux86-64"` is an emulated target.
- Repositories:
  - [https://git.openembedded.org/openembedded-core/](https://git.openembedded.org/openembedded-core/)
  - [https://git.openembedded.org/bitbake/](https://git.openembedded.org/bitbake/)

---
layout: default
---

::title::

Yocto fundamentals: The full picture

::body::

<img src="/images/yocto-architecture-workflow.png" class="max-h-96 mx-auto" alt="OpenEmbedded architecture workflow" />

---
layout: default
---

::title::

The OpenEmbedded-Core reference overview

::body::

- Repositories:
  - `git clone -b wrynose https://git.openembedded.org/openembedded-core`
  - `git clone -b 2.18 https://git.openembedded.org/bitbake`
- `wrynose` is the current release (Yocto 6.0, LTS).
- A new version is released every 6 months and maintained for 7 months.
- LTS releases are maintained for 4 years (6.0 Wrynose until at least April 2030).
- Info on release dates and maintenance periods is available on the Yocto website: [https://wiki.yoctoproject.org/wiki/Releases](https://wiki.yoctoproject.org/wiki/Releases)
- Layers can be found on the layer index: [https://layers.openembedded.org](https://layers.openembedded.org)

---
layout: default
---

::title::

The OpenEmbedded-Core source organization

::body::

```text
openembedded-core$ tree -L 1
.
├── meta
├── meta-selftest
├── meta-skeleton
├── oe-init-build-env
└── scripts
```

- `meta` contains the core metadata: recipes, classes, machine and distro configuration.
- `meta-selftest` contains recipes and classes used by the build system self-tests.
- `meta-skeleton` contains example recipes for BSP and kernel development.
- `scripts` contains helper scripts, including `devtool` and `oe-init-build-env`.
- `bitbake` is a separate repository, cloned next to OE-Core or fetched by KAS.

---
layout: default
---

::title::

The Yocto documentation

::body::

- During the course please always refer to the official Yocto documentation: [https://docs.yoctoproject.org/](https://docs.yoctoproject.org/) and [https://docs.yoctoproject.org/singleindex.html](https://docs.yoctoproject.org/singleindex.html)
- There you can find all you need; it is a very complete resource.
- When you need an example of a recipe, browse openembedded-core and meta-openembedded.
- The Yocto Project is very well documented and provides a lot of examples.
- The more you study the code in the Yocto Project, the less you'll need Stack Overflow answers.
