# Lab 00 — Setup

## Goal

Verify the host, install KAS, fetch the Yocto layers and inspect the resolved
configuration.

## Steps

From the `labs/` directory:

```bash
pipx install kas
kas --version
```

KAS 5.5 reports configuration format version 23 and earliest compatible
version 1.

Fetch the repositories and generate the build configuration:

```bash
./kas.sh checkout kas/qemu.yml
```

Inspect the layers that KAS configured:

```bash
./kas.sh shell kas/qemu.yml -c 'bitbake-layers show-layers'
```

You should see:

| Layer | Purpose |
| --- | --- |
| `core` | OpenEmbedded-Core |
| `openembedded-layer`, `meta-python`, `networking-layer`, `multimedia-layer` | meta-openembedded |
| `meta-training` | the training layer in this repository |

## Inspect the generated configuration

```bash
cat build/conf/local.conf
cat build/conf/bblayers.conf
```

`local.conf` contains `MACHINE ??= "qemux86-64"`, `DISTRO ??= "nodistro"` and
the training image features. `bblayers.conf` lists the layers above.

## Troubleshooting

- **`BitBake` fails with "User namespaces are not usable"**: enable
  unprivileged user namespaces on the host, or use `kas-container`.
- **Network/download errors**: check proxy settings and retry; KAS keeps
  partial checkouts in `work/`.
- **Disk space**: the first build needs tens of gigabytes. Use `df -h` before
  starting.

## Challenge

Run:

```bash
./kas.sh dump kas/qemu.yml
```

Identify the resolved `machine`, `distro`, `target` and the layer paths.
