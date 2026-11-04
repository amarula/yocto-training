---
layout: center
class: text-center
---

# Yocto

## Images

---
layout: default
---

::title::

Yocto Images

::body::

The final goal of Yocto is to produce images for the target. How can this be achieved?

- An image is the top-level recipe and is used alongside the machine definition.
- Whereas the machine describes the hardware used and its capabilities, the image is architecture-agnostic and defines how the root filesystem is built, with what packages.
- By default, several images are provided in Poky:
  - `meta*/recipes*/images/*.bb`

---
layout: default
---

::title::

Yocto Common Images

::body::

Yocto already provides a list of common images. Those images can be used as a base for a Linux distribution and to initially generate a minimal filesystem that allows testing the platform:

- `core-image-base`: console-only image, with full support of the hardware.
- `core-image-minimal`: small image, capable of booting a device.
- `core-image-weston`: image with basic Wayland support.
- `core-image-rt`: `core-image-minimal` with real-time tools and test suite.

---
layout: default
---

::title::

Yocto Common Images

::body::

Images are recipes that inherit the `core-image` class. What tasks should the core image class implement?

- `do_rootfs` prepares all the packages to install and populates the final rootfs, taking into account what we ask to include/exclude in the final image.
- `do_image` generates the image.
- `do_image_complete` is used for post-processing commands.

And we need to exclude some of the common steps:

```text
do_fetch[noexec] = "1", do_unpack[noexec] = "1", do_patch[noexec] = "1",
do_configure[noexec] = "1"
do_compile[noexec] = "1", do_install[noexec] = "1"
do_package[noexec] = "1"
```

---
layout: default
---

::title::

Yocto Images variables

::body::

What are the variables that are used to customize the image result?

| Variable | Description |
| --- | --- |
| `IMAGE_BASENAME` | the name of the output image files. Defaults to `${PN}`. |
| `IMAGE_INSTALL` | list of packages and package groups to install in the generated image. |
| `IMAGE_ROOTFS_SIZE` | size of the root filesystem. |
| `IMAGE_FEATURES` | features to enable in the image. |
| `IMAGE_FSTYPES` | filesystem types to generate. |
| `IMAGE_LINGUAS` | languages to include. |
| `IMAGE_PKGTYPE` | package type used for the image. |
| `IMAGE_POSTPROCESS_COMMAND` | commands to run after image generation. |
| `EXTRA_IMAGEDEPENDS` | additional dependencies for the image. |

Since Yocto 6.0, WIC is maintained as a separate project; OE-Core provides the `wic` recipe and the `image_types_wic` class.
