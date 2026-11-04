---
layout: center
class: text-center
---

# Yocto

## System Integration

---
layout: default
---

::title::

What is system integration?

::body::

- An image is more than a kernel and a root filesystem.
- It also contains services, users and groups, configuration files, alternatives and package management.
- Keep integration metadata in recipes, classes and layers, not in `local.conf`.
- Keep hardware details in the machine/BSP layer and policy in the distro layer.
- Reuse existing recipes and classes before writing new ones.

---
layout: default
---

::title::

Choosing the init manager

::body::

- `INIT_MANAGER` selects the init system. OE-Core 6.0 defaults to `systemd`:

```text
INIT_MANAGER = "systemd"
# or
INIT_MANAGER = "sysvinit"
```

- `init-manager-systemd.inc` adds `systemd usrmerge` to `DISTRO_FEATURES`.
- A distro layer can override the default.
- systemd units are the default; SysV init scripts are still supported.
- Check the result:

```bash
bitbake -e | grep ^DISTRO_FEATURES=
```

---
layout: default
---

::title::

A systemd service recipe

::body::

```text
inherit systemd

SRC_URI = "file://training-service.service"
S = "${UNPACKDIR}"

SYSTEMD_SERVICE:${PN} = "training-service.service"
SYSTEMD_AUTO_ENABLE:${PN} = "enable"

do_install() {
    install -d ${D}${systemd_system_unitdir}
    install -m 0644 ${S}/training-service.service ${D}${systemd_system_unitdir}/
}
```

- `systemd.bbclass` adds the service to the package and wires the postinst/prerm scripts.
- `SYSTEMD_SERVICE` lists the units; `SYSTEMD_AUTO_ENABLE` enables them at boot.
- `systemd_system_unitdir` is `/lib/systemd/system` (or `/usr/lib/systemd/system` with usrmerge).

---
layout: default
---

::title::

A systemd unit example

::body::

```text
[Unit]
Description=Yocto training service
After=network.target

[Service]
Type=simple
User=training
Group=training
StateDirectory=training
ExecStart=/usr/bin/training-service
Restart=on-failure

[Install]
WantedBy=multi-user.target
```

- `WantedBy=multi-user.target` is required for `systemctl enable`.
- `Type` can be `simple`, `oneshot` or `forking`.
- `StateDirectory=` creates a writable directory with the right ownership.
- Only use `After=network.target` if the service needs the network.

---
layout: default
---

::title::

Users and groups

::body::

```text
inherit useradd

USERADD_PACKAGES = "${PN}"
USERADD_PARAM:${PN} = "-r -s /bin/false -d /var/lib/training -g training training"
GROUPADD_PARAM:${PN} = "-r training"
```

- `USERADD_PACKAGES` lists the packages that need the user or group.
- The commands run at rootfs time, before the service starts.
- For reproducible UIDs/GIDs, inherit `useradd-staticids` and provide `USERADD_UID_TABLES`/`USERADD_GID_TABLES`.
- Use `-r` for system accounts and `-s /bin/false` for non-login services.

---
layout: default
---

::title::

update-alternatives

::body::

```text
inherit update-alternatives

ALTERNATIVE:${PN} = "mycmd"
ALTERNATIVE_LINK_NAME[mycmd] = "${bindir}/mycmd"
ALTERNATIVE_TARGET[mycmd] = "${bindir}/mycmd.real"
ALTERNATIVE_PRIORITY[mycmd] = "20"
```

- Used when several packages provide the same command (e.g. `sh`, `awk`, `vi`).
- The highest priority wins; links are managed under `/etc/alternatives`.
- On target: `update-alternatives --list mycmd`, `update-alternatives --config mycmd`.

---
layout: default
---

::title::

Package post-install scripts

::body::

```text
pkg_postinst:${PN}() {
    # runs while the root filesystem is built
}

pkg_postinst_ontarget:${PN}() {
    # runs on the target at first boot
}
```

- `pkg_postinst` runs during rootfs creation (or at first boot if the package manager defers it).
- `pkg_postinst_ontarget` is always deferred to first boot.
- `pkg_preinst`, `pkg_prerm` and `pkg_postrm` are also available.
- Avoid network operations and long-running work in `pkg_postinst`; make scripts idempotent.
- `PACKAGE_WRITE_DEPS` lists host tools needed by the scripts.

---
layout: default
---

::title::

Package management

::body::

- `PACKAGE_CLASSES` selects the package format:

```text
PACKAGE_CLASSES = "package_ipk"
# or "package_rpm" or "package_deb"
```

- OE-Core 6.0 defaults to `package_ipk`.
- `IMAGE_FEATURES:append = " package-management"` installs the package manager and keeps its database.
- Package managers: `opkg` (ipk), `dnf` (rpm), `apt` (deb).
- Use `IMAGE_INSTALL` for build-time selection; use the package manager for development and debugging.

---
layout: default
---

::title::

Package feeds

::body::

```text
PACKAGE_FEED_URIS = "https://example.com/feeds"
PACKAGE_FEED_BASE_PATHS = "ipk"
PACKAGE_FEED_ARCHS = "all core2-64"
```

- Build the feed metadata:

```bash
bitbake package-index
```

- Publish `tmp/deploy/ipk` (or `rpm`/`deb`) to the feed URL.
- On target:

```bash
opkg update
opkg install htop
```

- Use HTTPS and signed packages for production feeds.

---
layout: default
---

::title::

Configuration files and /etc

::body::

- Install configuration files in `do_install` and package them with `FILES:${PN}`.
- Mark files that users may edit as conffiles:

```text
CONFFILES:${PN} += "${sysconfdir}/training.conf"
```

- `CONFFILES` preserves local changes on package upgrades.
- Ship sane defaults in the recipe; avoid hand-editing `/etc` on the target.
- For read-only rootfs, keep configuration in a writable overlay or generate it at first boot.

---
layout: default
---

::title::

Runtime integration and read-only rootfs

::body::

- `read-only-rootfs` makes the root filesystem immutable.
- `overlayfs-etc` keeps `/etc` writable on top of a read-only rootfs.
- `pkg_postinst_ontarget` runs on first boot; make it idempotent and fast.
- systemd can create runtime state:
  - `StateDirectory=` for persistent state
  - `RuntimeDirectory=` for `/run`
  - `CacheDirectory=` for cache data
- Keep persistent application data on a separate writable partition.

---
layout: default
---

::title::

Debugging system integration

::body::

- `systemctl status <service>`
- `journalctl -u <service>`
- `systemctl list-units --failed`
- `systemctl cat <service>`
- Build logs:
  - `tmp/work/<machine>/<recipe>/<version>/temp/log.do_install`
  - `tmp/work/<machine>/<recipe>/<version>/temp/log.do_package`
  - `tmp/work/<machine>/<image>/<version>/temp/log.do_rootfs`
- Inspect variables:

```bash
bitbake -e training-service | grep -E '^(SYSTEMD_|USERADD_|GROUPADD_)'
```

- Check package contents with `oe-pkgdata-util list-pkg-files -p training-service`.

---
layout: default
---

::title::

Hands-on lab: system integration

::body::

- Lab: `labs/exercises/10-systemd-service.md`
- The training layer includes `training-service` with a `training` user.
- Build and boot:

```bash
cd labs
./kas.sh build kas/qemu.yml
./kas.sh shell kas/qemu.yml -c 'runqemu qemux86-64 training-image'
```

- On target:

```bash
systemctl status training-service
journalctl -u training-service -n 20
id training
```

- Add `package-management` to the image, rebuild and inspect:

```text
IMAGE_FEATURES:append = " package-management"
```

```bash
opkg list-installed | head
```

- Challenge: add a second service that runs as `training`.

---
layout: default
---

::title::

Checkpoint: system integration

::body::

1. What does `SYSTEMD_SERVICE` tell the build system?
2. How do you create a user and group for a service?
3. When does `pkg_postinst` run versus `pkg_postinst_ontarget`?
4. What does `PACKAGE_CLASSES` control?
5. How do you enable a package feed on the target?
