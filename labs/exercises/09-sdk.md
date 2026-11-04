# Lab 09 — SDK and eSDK

## Goal

Build and install the standard SDK, cross-compile an application, then build
the extensible SDK and use `devtool` from it.

## Build the standard SDK

From the `labs/` directory:

```bash
./kas.sh shell kas/qemu.yml -c 'bitbake -c populate_sdk training-image'
ls -lh build/tmp/deploy/sdk/
```

The installer is a `.sh` file under `build/tmp/deploy/sdk/`.

## Install and use the SDK

```bash
./build/tmp/deploy/sdk/<sdk>-toolchain-<version>.sh -d /tmp/yocto-sdk
source /tmp/yocto-sdk/environment-setup-*
$CC meta-training/recipes-apps/hello/files/hello.c -o /tmp/hello-sdk
file /tmp/hello-sdk
```

`file` should report the target architecture (for QEMU, x86-64 Linux).

Inspect the toolchain environment:

```bash
echo $CC
echo $CROSS_COMPILE
echo $SDKTARGETSYSROOT
```

## Build the eSDK

```bash
./kas.sh shell kas/qemu.yml -c 'bitbake -c populate_sdk_ext training-image'
ls -lh build/tmp/deploy/sdk/
./build/tmp/deploy/sdk/<esdk>.sh -d /tmp/yocto-esdk
source /tmp/yocto-esdk/environment-setup-*
devtool --help
```

From the eSDK you can modify and build recipes without the full Yocto tree:

```bash
devtool modify hello
devtool build hello
devtool sdk-install htop
```

`devtool sdk-install` adds build dependencies to the eSDK; it does not install
packages on the target.

## Optional — devtool ide-sdk

```bash
devtool modify hello
devtool ide-sdk hello training-image
```

Use `-i none` to generate the configuration without launching an IDE, and
`-t user@host` to configure remote debugging.

## Notes

- Building the SDK creates a large installer and can take a significant amount
  of time and disk space.
- Keep the SDK and eSDK aligned with the image and its shared state.
- The SDK is relocatable; use `-d <dir>` to choose the install directory.

## Validation

- The SDK installer exists under `build/tmp/deploy/sdk/`.
- `$CC` produces a binary for the target architecture.
- `devtool --help` works from the eSDK environment.
