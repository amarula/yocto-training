---
layout: default
---

::title::

Recap

::body::

- Yocto build system: BitBake, metadata, OE-Core and layers
- Recipes, classes and bbappends
- Variables, overrides and package selection
- Layers, BSP and distro configuration
- Images, WIC, flashing and image inspection
- devtool and SDK/eSDK
- License compliance, SBOM and CVE checking
- KAS for reproducible multi-repository builds and CI

---
layout: default
---

::title::

Glossary (1 / 2)

::body::

| Term | Meaning |
| --- | --- |
| BitBake | task executor and scheduler |
| OE-Core | core metadata layer of the OpenEmbedded build system |
| Metadata | recipes, classes and configuration files |
| Recipe | `.bb` file describing how to fetch, build and package a component |
| Class | `.bbclass` file with reusable logic |
| Layer | collection of metadata that can be added to a build |
| Machine | hardware configuration (`conf/machine/*.conf`) |
| Distro | distribution policy configuration |

---
layout: default
---

::title::

Glossary (2 / 2)

::body::

| Term | Meaning |
| --- | --- |
| Image | top-level recipe that produces a root filesystem or disk image |
| BSP | board support package: machine, bootloader and kernel support |
| sstate | shared state cache used to speed up rebuilds |
| WIC | tool that creates partitioned disk images from `.wks` files |
| SDK / eSDK | application development kit / extensible SDK |
| SBOM | software bill of materials, generated as SPDX |
| KAS | YAML-based project setup and release tool |

---
layout: default
---

::title::

References

::body::

- Yocto documentation: [https://docs.yoctoproject.org/](https://docs.yoctoproject.org/)
- Reference manual: [https://docs.yoctoproject.org/ref-manual/](https://docs.yoctoproject.org/ref-manual/)
- Migration guides: [https://docs.yoctoproject.org/migration-guides/](https://docs.yoctoproject.org/migration-guides/)
- Layer index: [https://layers.openembedded.org/](https://layers.openembedded.org/)
- OpenEmbedded-Core: [https://git.openembedded.org/openembedded-core/](https://git.openembedded.org/openembedded-core/)
- BitBake: [https://git.openembedded.org/bitbake/](https://git.openembedded.org/bitbake/)
- KAS: [https://github.com/siemens/kas](https://github.com/siemens/kas)
- Release information: [https://wiki.yoctoproject.org/wiki/Releases](https://wiki.yoctoproject.org/wiki/Releases)

---
layout: default
---

::title::

Next steps

::body::

- Complete the labs and the capstone.
- Build a BSP for your own board: machine, bootloader, kernel and WIC layout.
- Read the migration guides before moving to a new LTS.
- Upstream fixes to OE-Core and third-party layers.
- Explore advanced topics:
  - multiconfig and multilib
  - sstate mirrors and build performance
  - security, secure boot and OTA updates
  - CI automation and SBOM/CVE reporting
- Keep the KAS lockfile and SBOM with every release.

---
layout: center
class: text-center
---

# Questions?

<img src="/images/questions.png" class="max-h-64 mx-auto mt-8" alt="Questions" />
