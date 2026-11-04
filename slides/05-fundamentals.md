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

Yocto fundamentals: Poky

::body::

- We need a way to organize all the core parts and download them.
- Poky is the git repository that organizes all the core components like: openembedded-core, yocto-docs and meta-yocto.
- Poky is also the reference distro provided by the Yocto Project.
- meta-poky is the reference distribution.

[https://git.yoctoproject.org/poky/](https://git.yoctoproject.org/poky/)

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

The poky reference overview

::body::

- You can find it here: [https://git.yoctoproject.org](https://git.yoctoproject.org)
- To download it:
  - `git clone -b wrynose https://git.yoctoproject.org/git/poky`
  - `wrynose` is the current release (Yocto 6.0, LTS)
- A new version is released every 6 months and maintained for 7 months.
- LTS releases are maintained for 4 years (6.0 Wrynose until at least April 2030).
- Info on release dates and maintenance periods is available on the Yocto website: [https://wiki.yoctoproject.org/wiki/Releases](https://wiki.yoctoproject.org/wiki/Releases)

---
layout: default
---

::title::

The poky source code organization

::body::

```text
poky$ tree -L 1
.
├── bitbake
├── contrib
├── documentation
├── meta
├── meta-poky
├── meta-selftest
├── meta-skeleton
├── meta-yocto-bsp
└── scripts
```

- `bitbake` holds scripts used by the BitBake command-line tools.
- `documentation` holds all the Yocto Project docs, including the way to generate PDF or HTML.
- `meta` contains the openembedded-core metadata.
- `meta-skeleton` contains recipes for BSP and kernel development.
- `meta-poky` holds the configuration of the poky reference distribution.
- `meta-yocto-bsp` contains the configuration of Yocto reference hardware boards.
- `scripts` contains all you need to set up the environment and build tools.

---
layout: default
---

::title::

The poky documentation

::body::

- During the course please always refer to the official Yocto documentation: [https://docs.yoctoproject.org/](https://docs.yoctoproject.org/) and [https://docs.yoctoproject.org/singleindex.html](https://docs.yoctoproject.org/singleindex.html)
- There you can find all you need; it is a very complete resource.
- When you need an example of a recipe, please navigate the poky project and the meta layers.
- The Yocto Project is very well documented and provides a lot of examples.
- The more you study the code in the Yocto Project, the less you'll need Stack Overflow answers.
