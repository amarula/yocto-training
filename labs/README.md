# Yocto Training Labs

Hands-on project for the Yocto Training course. The labs use **KAS** to fetch
BitBake, OpenEmbedded-Core, meta-openembedded and the training layer, generate
`local.conf`/`bblayers.conf`, and build a small image.

## Prerequisites

- Linux host (Ubuntu 24.04 recommended)
- Python 3.9+, `pipx`, `git`
- At least 50 GB free disk space and 8 GB RAM
- Network access for the first build
- On Ubuntu 24.04+, BitBake needs unprivileged user namespaces. If the build
  fails with an AppArmor/user-namespace error, use `kas-container` or enable
  unprivileged user namespaces on the host.

## Quick start

```bash
cd labs
pipx install kas
./kas.sh build kas/qemu.yml
./kas.sh shell kas/qemu.yml -c 'runqemu qemux86-64 training-image'
```

The `kas.sh` wrapper keeps repository checkouts and build output inside
`labs/`:

- `labs/work/` — KAS repository checkouts
- `labs/build/` — Yocto build directory

Both are ignored by git.

## What gets built

`training-image` is based on `core-image-minimal` and adds:

- `hello` — a small C application
- `training-info` — a target information script
- a kernel configuration fragment enabling `/proc/config.gz`
- SSH support
- a WIC image

## Board build

```bash
./kas.sh build kas/imx8mp.yml
```

This uses the `imx8mp-lpddr4-evk` machine from meta-freescale. The course board
machine (`imx8mp-icore-ctouch2-of10`) is provided by the customer BSP layer;
replace the machine in `kas/imx8mp.yml` or add the BSP repository when using
the real board.

## Lab index

| Lab | Topic |
| --- | --- |
| `exercises/00-setup.md` | Install KAS, fetch layers, inspect the resolved configuration |
| `exercises/01-build-and-run.md` | Build the image and boot it in QEMU |
| `exercises/02-inspect-build.md` | Explore the build directory, metadata and task graph |
| `exercises/03-variables.md` | Variables, overrides and `bitbake -e` (planned) |
| `exercises/04-hello-recipe.md` | Write and package a recipe (planned) |
| `exercises/05-layer-and-bbappend.md` | Create a layer and a `.bbappend` (planned) |
| `exercises/06-devtool.md` | Modify, patch and finish a recipe with devtool (planned) |
| `exercises/07-image-and-wic.md` | Customize the image and the WIC layout |
| `exercises/08-kernel-fragment.md` | Add a kernel configuration fragment |
| `exercises/09-sdk.md` | Build and use the SDK/eSDK (planned) |
| `exercises/10-systemd-service.md` | Add a systemd service (planned) |
| `exercises/11-capstone.md` | Build a complete custom image (planned) |

## Validate a completed lab

```bash
./scripts/check-lab.sh
```

## Notes

- The first build fetches several repositories and compiles a full toolchain.
  For classroom use, pre-populate `labs/build/downloads` and
  `labs/build/sstate-cache`, or use a shared `DL_DIR`/`SSTATE_DIR`.
- The lab recipes use `${UNPACKDIR}` for local `file://` sources, as required by
  Yocto 5.3 and later.
- KAS warns when repositories use a `branch` without a commit. Use
  `./kas.sh lock kas/qemu.yml` to generate a lockfile, then commit it for a
  reproducible release.
