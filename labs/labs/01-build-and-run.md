# Lab 01 — Build and run

## Goal

Build `training-image` for QEMU, boot it, and verify the training applications.

## Build

From the `labs/` directory:

```bash
./kas.sh build kas/qemu.yml
```

The first build fetches sources and compiles the toolchain, so it can take a
long time. Subsequent builds are fast thanks to the shared state cache.

The output is under:

```text
build/tmp/deploy/images/qemux86-64/
```

Look for `training-image-qemux86-64.rootfs.wic` and the package manifest.

## Run

```bash
./kas.sh shell kas/qemu.yml -c 'runqemu qemux86-64 training-image'
```

The image enables serial autologin for the `root` user. Once the prompt is
available, run:

```bash
hello
training-info
```

Expected output:

```text
Hello from the Yocto training image!
=== Yocto training image ===
Linux qemux86-64 ...
```

Check the kernel configuration fragment:

```bash
zcat /proc/config.gz | grep IKCONFIG
```

Expected:

```text
CONFIG_IKCONFIG=y
CONFIG_IKCONFIG_PROC=y
```

Exit QEMU with `Ctrl-A`, then `X`.

## Challenge

Change the message in `meta-training/recipes-apps/hello/files/hello.c`, rebuild
and boot again. BitBake should detect the changed source and recompile only the
`hello` recipe.

```bash
./kas.sh build kas/qemu.yml
```

Use `bitbake -e hello | grep ^S=` to see where the source is unpacked.
