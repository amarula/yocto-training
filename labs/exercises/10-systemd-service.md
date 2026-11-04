# Lab 10 — Systemd service and system integration

## Goal

Inspect a systemd service recipe and its user, verify the service at runtime,
and enable package management on the target.

## Inspect the recipe

From the `labs/` directory:

```bash
./kas.sh shell kas/qemu.yml -c \
  "bitbake -e training-service | grep -E '^(SYSTEMD_|USERADD_|GROUPADD_)'"
```

Note that package-specific variables are shown with the package name, for
example:

```text
SYSTEMD_SERVICE:training-service="training-service.service"
SYSTEMD_AUTO_ENABLE:training-service="enable"
USERADD_PARAM:training-service="-r -s /bin/false -d /var/lib/training -g training training"
GROUPADD_PARAM:training-service="-r training"
```

## Build and verify at runtime

```bash
./kas.sh build kas/qemu.yml
./kas.sh shell kas/qemu.yml -c 'runqemu qemux86-64 training-image'
```

On the target:

```bash
systemctl status training-service
journalctl -u training-service -n 20
systemctl cat training-service
id training
ls -ld /var/lib/training
```

Expected:

- the service is `active (running)`;
- the journal contains `training-service: running as training`;
- the `training` user and group exist;
- `/var/lib/training` is owned by `training`.

## Enable package management

Add the feature to `meta-training/recipes-core/images/training-image.bb`:

```text
IMAGE_FEATURES:append = " package-management"
```

Rebuild, boot and inspect the package database:

```bash
./kas.sh build kas/qemu.yml
./kas.sh shell kas/qemu.yml -c 'runqemu qemux86-64 training-image'
opkg list-installed | head
```

## Challenge — add a second service

Create `training-logger.service` and `training-logger.sh` in the training
layer. Run it as the `training` user and install it with a second recipe or
the same one. Verify it with `systemctl status training-logger`.

## Challenge — conffile or alternative

- Add a configuration file to `training-service` and mark it with
  `CONFFILES:${PN}`.
- Or install two implementations of a command and switch between them with
  `update-alternatives`.

## Validation

```bash
./scripts/check-lab.sh
```
