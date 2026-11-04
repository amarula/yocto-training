---
layout: default
---

::title::

Yocto How handle complex release using repo

::body::

- `repo` is a Google tool introduced together with Android AOSP.
  - Android AOSP is the Android operating system shipped with mobile devices.
- `repo` is open source and developed in Python 3.
- `repo` uses a manifest file and git to store versioning and releases.
- `repo` is able to fetch code; management of the Yocto configuration must be done separately or inside the manifest.

---
layout: default
---

::title::

Yocto How handle complex release using repo

::body::

```xml
<?xml version="1.0" encoding="UTF-8"?>
<manifest>
  <default sync-j="4" revision="kirkstone"/>
  <remote fetch="https://git.yoctoproject.org/git" name="yocto"/>
  <remote fetch="https://github.com/Freescale" name="freescale"/>
  <remote fetch="https://github.com/openembedded" name="oe"/>
  <remote fetch="https://github.com/manojams" name="meta-imx8mp"/>
  <remote fetch="https://github.com/meta-qt5" name="qt5"/>
  <project remote="yocto" name="poky" path="sources/poky"/>
  <project remote="yocto" name="meta-freescale" path="sources/meta-freescale"/>
  <project remote="oe" name="meta-openembedded" path="sources/meta-openembedded"/>
  <project remote="meta-imx8mp" name="fsl-community-bsp-base" path="sources/base">
    <linkfile dest="README" src="README"/>
    <linkfile dest="setup-environment" src="setup-environment"/>
  </project>
  <project remote="meta-imx8mp" name="meta-freescale-3rdparty" path="sources/meta-freescale-3rdparty"/>
  <project remote="freescale" name="meta-freescale-distro" path="sources/meta-freescale-distro"/>
  <project remote="freescale" name="Documentation" path="sources/Documentation"/>
  <project remote="qt5" name="meta-qt5" path="sources/meta-qt5"/>
</manifest>
```

---
layout: default
---

::title::

Yocto How handle complex release using repo

::body::

- `repo` allows downloading the project:
  - `mkdir project`
  - `repo init -u https://git.example.net/manifest.git -b <branch> -m <manifest name>` default is `default.xml`
  - `repo sync -j<level of parallelism>` default is 4
- Documentation: [https://source.android.com/source/using-repo.html](https://source.android.com/source/using-repo.html)

---
layout: default
---

::title::

Yocto How handle complex release using repo

::body::

- A release can happen by creating a specific XML file for the release.
- We need to point for each project to the tag we want to download.
- We need to not tag projects that are kept by the community and not handled by us.

```xml
<?xml version="1.0" encoding="UTF-8"?>
<manifest>
  <remote name="anyproject"
          fetch=".."
          review="https://review-server" />
  <default revision="refs/tags/appA_0049"
           remote="anyproject"
           sync-j="4"
           sync-c="true" />
  <project path="linux-c" name="customer_bsp/linux-c" revision="refs/tags/appA_0049" />
  <project path="build" name="customer_bsp/build" revision="refs/tags/appA_0049" />
</manifest>
```
