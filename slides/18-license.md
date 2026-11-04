---
layout: default
---

::title::

Achieving GPL compliance

::body::

- This is not legal advice.
- Open source licenses.
- Products in the market have problems with open source packages.
- Proprietary licenses alongside open source ones.

Open source license compliance is a critical point for most products introduced in the market nowadays, as open source code needs to live alongside proprietary code.

---
layout: default
---

::title::

Achieving GPL why we need to care?

::body::

- Selling an embedded device typically involves distribution of open source software.
- For devices: what is on the device when it is shipped to a customer?
- For downloads: what is in the file a customer downloads?

Make those steps automatic.

---
layout: default
---

::title::

Copyleft freedom and obligation

::body::

- Copyleft licenses give us the freedom to use third-party packages.
- Packages used with third-party licenses should be used with all the obligations of the license.

There are two projects that we must use when we build a Linux distribution:

- Toolchain (`GPL-2.0-only`, `GPL-2.0-or-later` and `GPL-3.0-or-later`)
- Linux kernel (`GPL-2.0-only`)

A real Yocto distribution can contain a huge amount of packages. So how does Yocto help to deal with it?

---
layout: default
---

::title::

Yocto GPL compliance

::body::

- Packages in Yocto include the `LICENSE` information in each package.
- Copyleft requires providing the source code.
- Yocto collects source code for any recipe that is built, the patches applied to it and how it is configured.
- Yocto uses archiver classes to do it.
- Yocto provides license text because this is required to be compliant with open source rules.
- The Yocto SDK does not guarantee license compliance.

---
layout: default
---

::title::

Yocto GPL compliance

::body::

- Copy licenses from `${DEPLOY_DIR}/licenses`
  - may need some post-processing
- If you want to include the license in the distribution:
  - `COPY_LIC_MANIFEST = "1"`
  - `COPY_LIC_DIRS = "1"`
- If you want to create a license package, then:
  - set `LICENSE_CREATE_PACKAGE = "1"`
  - needed to provide package license updates

---
layout: default
---

::title::

Yocto SBOM and CVE checking

::body::

- Yocto 6.0 generates SPDX 3 SBOMs by default through the `create-spdx` class.
- SBOMs are deployed under `${DEPLOY_DIR}/spdx`.
- The `sbom-cve-check` class checks the generated SBOM against CVE databases.
- The old `cve-check` class is obsolete in 6.0; use `sbom-cve-check`.
- SBOMs are the basis for license and security compliance audits.

---
layout: default
---

::title::

Yocto Excluding license

::body::

- `INCOMPATIBLE_LICENSE` provides a way to exclude them.
- `INCOMPATIBLE_LICENSE` is applied "only on target packages".
- [https://layers.openembedded.org/layerindex/branch/master/layer/meta-gplv2/](https://layers.openembedded.org/layerindex/branch/master/layer/meta-gplv2/) is deprecated and is not recommended for new products; migrate recipes to current license identifiers instead.

Example:

```text
INCOMPATIBLE_LICENSE = "GPL-3.0-or-later"
```

An alternative method is license flags:

- `LICENSE_FLAGS_ACCEPTED` is mostly used to enable commercial licenses that are restricted.

---
layout: default
---

::title::

Yocto How handle complex release

::body::

In order to handle releases that include multiple layers we need a way to organize them properly:

- KAS [https://github.com/siemens/kas](https://github.com/siemens/kas) (Siemens)

KAS uses a YAML configuration file to download all the needed software and to handle complex releases.

We need to be able to tag the project and to easily download it. KAS lockfiles and tagged repositories provide reproducible releases; the next chapter shows the details.
