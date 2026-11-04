# Lab 12 — Build internals and performance

## Goal

Measure disk usage, inspect shared state and feature switches, enable
`rm_work` and `buildhistory`, and use the sstate management tool.

## Baseline

From the `labs/` directory, after at least one build:

```bash
du -sh build/tmp build/sstate-cache build/downloads
```

Inspect the effective features and package configuration:

```bash
./kas.sh shell kas/qemu.yml -c \
  "bitbake -e | grep -E '^(DISTRO_FEATURES|MACHINE_FEATURES)='"
./kas.sh shell kas/qemu.yml -c \
  "bitbake -e dropbear | grep ^PACKAGECONFIG="
```

## Shared state

Check why a task would rebuild:

```bash
./kas.sh shell kas/qemu.yml -c 'bitbake -S printdiff training-image'
```

Inspect the sstate cache:

```bash
ls build/sstate-cache | head
du -sh build/sstate-cache
```

Run the sstate cleanup tool in dry-run mode:

```bash
python3 work/core/scripts/sstate-cache-management.py \
  --cache-dir build/sstate-cache -n
```

Read `--help` before removing anything; `-n` is a dry run.

## buildhistory

Add the following to the `local_conf_header` section of
`labs/kas/base.yml`:

```text
INHERIT += "buildhistory"
BUILDHISTORY_COMMIT = "1"
```

Rebuild and inspect the history:

```bash
./kas.sh build kas/qemu.yml
ls build/buildhistory/
git -C build/buildhistory log --oneline | head
buildhistory-diff
```

On a second build, `buildhistory-diff` shows what changed.

## rm_work

Add `rm_work` to the same `local_conf_header`:

```text
INHERIT += "rm_work"
RM_WORK_EXCLUDE += "hello"
```

Rebuild and compare the `build/tmp` size:

```bash
du -sh build/tmp
```

The `hello` work directory should remain because it is excluded; most other
work directories are removed. Do not use `rm_work` while debugging a recipe.

## Challenge — feature switch

Add a feature change to `local_conf_header`:

```text
DISTRO_FEATURES:remove = " x11"
```

Rebuild and measure the time and disk usage. Then remove the line and rebuild
to restore the original configuration.

## Cleanup

Remove the `INHERIT`, `BUILDHISTORY_*`, `RM_WORK_EXCLUDE`, `rm_work` and
`DISTRO_FEATURES` lines added for the lab. Rebuild once to restore the normal
configuration.

## Validation

```bash
./scripts/check-lab.sh
```
