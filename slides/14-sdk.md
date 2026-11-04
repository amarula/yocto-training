---
layout: default
---

::title::

Yocto SDK

::body::

- Not always can we give our Yocto BSP to external parties.
- Developers should be able to work without having the full OS to work with applications.
- We need a way to generate an installable bundle to redistribute to people that allows them to operate on the target.
- The SDK must be self-contained; this means all the tools should not depend on the host machine.

Yocto can generate an SDK compatible with the OS release, allowing you to deploy your applications.

---
layout: default
---

::title::

Yocto SDK

::body::

An SDK (Software Development Kit) is a set of tools allowing the development of applications for a given target (operating system, platform, environment, …).

It generally provides a set of tools including:

- Compilers or cross-compilers.
- Linkers.
- Library headers.
- Debuggers.
- Custom utilities.

---
layout: default
---

::title::

Yocto SDK

::body::

- Yocto allows creating a generic SDK that includes the toolchain, tools and basic libraries.
- … or creating a complete SDK including the reference libraries on the rootfs of the target.

Yocto generates an SDK that is basically a large executable archive as a bash script.

SDKs can be found under the `deploy/sdk` directory in the build result directory.

---
layout: default
---

::title::

Yocto SDK

::body::

The generic SDK contains:

- Tools that are mostly used by low-level developers for kernel and U-Boot.
- The generic target is called `meta-toolchain`:
  - `bitbake meta-toolchain` does the trick.
- After generation you can collect the `*sh` file inside the `deploy/sdk` directory.
- The generated SDK is compatible with the `MACHINE` defined in your `local.conf`.

Is that really used? Less than the customized SDK image. The latter is widely used by developers to generate an SDK not only to build low-level stuff but also to build complex applications.

---
layout: default
---

::title::

Yocto SDK

::body::

The SDK image contains:

- All tools to develop applications for that particular target.
- One task is dedicated to the process. The task behavior can vary between the images.
  - `bitbake -c populate_sdk core-image-full-cmdline`
- The result comes to the same directory as the generic SDK.
- The SDK is compatible with the `MACHINE` you are building for.

As we described, the SDK image contains even packages that the user can customize.

---
layout: default
---

::title::

Yocto SDK image example

::body::

How can we extend and customize the generic SDK?

- Two variables control what will be installed in the SDK:
  - `TOOLCHAIN_TARGET_TASK`
  - `TOOLCHAIN_HOST_TASK`
- `TOOLCHAIN_OUTPUTNAME` helps give a name to the resulting toolchain.

An easy way to add packages to the generated toolchain is to create `meta-toolchain.bbappend` or create your specific target `meta-toolchain-px30.bb` that requires `meta-toolchain.bb` and adds your packages.

```text
TOOLCHAIN_HOST_TASK:append = " nativesdk-curl"
TOOLCHAIN_TARGET_TASK:append = " openssl-dev"
```
