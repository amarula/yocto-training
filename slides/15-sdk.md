---
layout: center
class: text-center
---

# Yocto

## SDK

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
- For a self-contained SDK that also includes the build system, use the extensible SDK: `bitbake -c populate_sdk_ext <image>`.

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

---
layout: default
---

::title::

Standard SDK workflow

::body::

```bash
# Build the SDK
bitbake -c populate_sdk training-image

# Install it into a chosen directory
./tmp/deploy/sdk/<sdk>-toolchain-<version>.sh -d /opt/yocto-sdk

# Use the cross-toolchain
source /opt/yocto-sdk/environment-setup-*
$CC hello.c -o hello
file hello
```

- The environment exports `CC`, `CXX`, `CROSS_COMPILE`, `SDKTARGETSYSROOT` and `PKG_CONFIG_SYSROOT_DIR`.
- Use `$CC` (and `$CXX`) rather than the host compiler.
- `file hello` should report the target architecture.

---
layout: default
---

::title::

SDK installation and relocation

::body::

- The installer accepts `-d <dir>` and the SDK is relocatable.
- `environment-setup-*` sets the cross-toolchain, sysroot and pkg-config paths.
- Key variables:
  - `SDKTARGETSYSROOT` — target sysroot
  - `TOOLCHAIN_OUTPUTNAME` — installer name
  - `SDK_TITLE`, `SDK_VERSION` — metadata shown by the installer
- The SDK is self-contained; do not mix host and target headers or libraries.
- Use the SDK's `sysroots/` to inspect target libraries.

---
layout: default
---

::title::

Extensible SDK (eSDK)

::body::

```bash
bitbake -c populate_sdk_ext training-image
./tmp/deploy/sdk/<esdk>.sh -d /opt/yocto-esdk
source /opt/yocto-esdk/environment-setup-*
devtool --help
```

- The eSDK includes BitBake, `devtool`, metadata and a locked sysroot.
- Developers can add, modify and build recipes without the full Yocto tree.
- `devtool sdk-install <package>` adds a build dependency to the eSDK.
- `devtool sdk-update` updates the eSDK from `SDK_UPDATE_URL`.

---
layout: default
---

::title::

eSDK configuration

::body::

```text
SDK_EXT_TYPE = "full"          # or "minimal"
SDK_INCLUDE_TOOLCHAIN = "1"
SDK_INCLUDE_PKGDATA = "0"
SDK_INCLUDE_NATIVESDK = "0"
SDK_INCLUDE_BUILDTOOLS = "1"
SDK_UPDATE_URL = "https://example.com/sdk-updates"
```

- `full` includes the toolchain and package data; `minimal` is smaller and relies on `devtool sdk-install`.
- `ESDK_LOCALCONF_ALLOW` and `ESDK_LOCALCONF_REMOVE` control which `local.conf` variables are kept.
- `ESDK_CLASS_INHERIT_DISABLE` (default `buildhistory`) controls inherited classes.
- Keep the eSDK, its lockfile and the image's shared state consistent.

---
layout: default
---

::title::

devtool ide-sdk

::body::

```bash
devtool modify hello
devtool ide-sdk hello training-image
```

- `modified` mode: workspace source, target image and debug configuration.
- `shared` mode: cross-toolchain and shared sysroot.
- `-i code` (default) or `-i none`.
- `-t user@host` configures remote debugging on a running target.
- Requires an image recipe for the target and, for C/C++, a debugger/gdbserver.

---
layout: default
---

::title::

Hands-on lab: SDK

::body::

- Lab: `labs/exercises/09-sdk.md`
- Build and install the standard SDK:

```bash
cd labs
./kas.sh shell kas/qemu.yml -c 'bitbake -c populate_sdk training-image'
ls build/tmp/deploy/sdk/
```

- Install it and cross-compile `hello.c`:

```bash
./build/tmp/deploy/sdk/<sdk>.sh -d /tmp/yocto-sdk
source /tmp/yocto-sdk/environment-setup-*
$CC hello.c -o hello
file hello
```

- Challenge: build the eSDK with `populate_sdk_ext` and run `devtool` from it.

---
layout: default
---

::title::

Checkpoint: SDK

::body::

1. What is the difference between a standard SDK and an eSDK?
2. How do you build and install the standard SDK?
3. Which variables control the SDK contents?
4. How do you add a build dependency to an eSDK?
5. What does `devtool ide-sdk` generate?
