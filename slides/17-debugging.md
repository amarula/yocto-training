---
layout: center
class: text-center
---

# Yocto

## Debugging and Troubleshooting

---
layout: default
---

::title::

Where failures happen

::body::

| Stage | First place to look |
| --- | --- |
| Parse | the parser error, `bitbake -p` |
| Fetch | `log.do_fetch`, `DL_DIR`, `SRC_URI` |
| Patch | `log.do_patch`, `devtool modify` |
| Configure | `log.do_configure`, `config.log` |
| Compile | `log.do_compile`, `devshell` |
| Package | `log.do_package`, `log.do_package_qa` |
| Rootfs | `log.do_rootfs` |
| Boot | serial console, `runqemu` |
| Runtime | `journalctl`, `dmesg`, `systemctl` |

---
layout: default
---

::title::

First response to a failed build

::body::

- Read the last error, not the first warning.
- Identify the recipe and the task that failed.
- Reproduce the failure with `bitbake <recipe>`.
- Collect all failures with `bitbake -k <target>`.
- Increase verbosity:
  - `-v` for more output
  - `-D` for debug output
  - `-l <domain>` for specific debug domains
- Find the task log in `tmp/work/<machine>/<recipe>/<version>/temp/`.

---
layout: default
---

::title::

Task logs

::body::

```text
tmp/work/<machine>/<recipe>/<version>/temp/
├── log.do_configure
├── log.do_compile
├── log.do_install
├── log.do_package
├── log.do_package_qa
├── run.do_compile
└── log.do_compile.<pid>
```

- `log.do_*` is the task output; `run.do_*` is the generated script.
- Image rootfs failures: `tmp/work/<machine>/<image>/<version>/temp/log.do_rootfs`.
- Rerun a task: `bitbake -c <task> -f <recipe>`.
- Clean levels:
  - `clean` — work directory
  - `cleansstate` — work directory and shared state
  - `cleanall` — downloads, work directory and shared state

---
layout: default
---

::title::

Inspecting variables with bitbake -e

::body::

```bash
bitbake -e <recipe> > /tmp/env.txt
grep -E '^(S|B|WORKDIR|D|SRC_URI|DEPENDS)=' /tmp/env.txt
```

- The output includes comments showing where each variable was set.
- Use `grep -B5` to see the assignment history.
- Global configuration:

```bash
bitbake -e | grep ^DISTRO_FEATURES=
```

- Pipe to `less` and search interactively for large environments.
- Compare the recipe environment with `bitbake -e` after a change.

---
layout: default
---

::title::

Why did it rebuild?

::body::

```bash
bitbake -S printdiff <target>
```

- Compares task signatures with the most recent build or shared state cache.
- Shows which variable or file invalidated a task.
- `bitbake -S none <target>` dumps signatures without executing tasks.
- OE-Core 6.0 defaults:
  - `BB_SIGNATURE_HANDLER = "OEEquivHash"`
  - `BB_HASHSERVE = "auto"`
- Check `SSTATE_DIR`, `SSTATE_MIRRORS` and hash equivalence when re-runs look wrong.

---
layout: default
---

::title::

Devshell and devtool

::body::

```bash
bitbake -c devshell <recipe>
bitbake -c devshell virtual/kernel
```

- Opens a shell in the task's work directory with the build environment.
- Reproduce the failing command manually and inspect `S`, `B` and `D`.
- `devtool modify <recipe>` for source changes and `devtool build`.
- `oe_runmake` and `EXTRA_OEMAKE` replicate the build.
- `devtool finish` keeps the fix as a patch in a layer.

---
layout: default
---

::title::

Fetch and checksum failures

::body::

- `do_fetch` errors: bad URL, network, authentication or missing checksum.
- Check `SRC_URI` and `DL_DIR`.
- Checksum mismatch: verify the source and update `SRC_URI[sha256sum]`; do not disable checks.
- Mirrors:
  - `PREMIRRORS` and `MIRRORS` for local mirrors
  - `BB_NO_NETWORK = "1"` to test an offline build
- `bitbake -c cleanall <recipe>` removes downloads, work and shared state; use it carefully.
- `devtool` and `recipetool` can generate or update checksums.

---
layout: default
---

::title::

Patch and configure failures

::body::

- `do_patch` conflicts:
  - read `log.do_patch`
  - rebase with `devtool modify`
  - `PATCHRESOLVE = "user"` for interactive resolution
- `do_configure` failures:
  - missing dependencies
  - wrong `--host`/`--build`
  - toolchain or sysroot problems
- Read `config.log` in `B`.
- Use `EXTRA_OECONF`, `EXTRA_OECMAKE` and `PACKAGECONFIG` to adjust the configuration.
- Rerun with `bitbake -c configure -f <recipe>`.

---
layout: default
---

::title::

Compile and link failures

::body::

- Read `log.do_compile`; the real compiler error is above `oe_runmake failed`.
- Check `S` and `B` for in-tree versus out-of-tree builds.
- Missing headers or libraries:
  - `DEPENDS` for build-time dependencies
  - `RDEPENDS` for runtime dependencies
- `CFLAGS`, `LDFLAGS` and `CXXFLAGS` come from the build system.
- Use `make V=1` or `devshell` to see the full command.
- `devtool modify` for a reproducible source fix.

---
layout: default
---

::title::

Package and QA failures

::body::

- `do_package`: files are not packaged.
  - check `FILES:${PN}` and `PACKAGES`
  - use `oe-pkgdata-util` to inspect package contents
- `do_package_qa`: QA errors.
  - `ERROR_QA`, `WARN_QA`
  - `INSANE_SKIP:${PN}` suppresses a specific check
- Runtime dependencies: `RDEPENDS:${PN}`.
- `do_rootfs` conflicts:
  - `PACKAGE_EXCLUDE`
  - `BAD_RECOMMENDATIONS`
  - `IMAGE_INSTALL`
- Logs: `log.do_package`, `log.do_package_qa`, `log.do_rootfs`.

---
layout: default
---

::title::

sstate and rebuild issues

::body::

- `SSTATE_DIR` is the shared state cache; `SSTATE_MIRRORS` adds remote caches.
- Clean commands:
  - `bitbake -c cleansstate <recipe>`
  - `bitbake -c cleanall <recipe>`
- Force or invalidate a task:
  - `bitbake -f -c <task> <recipe>`
  - `bitbake -C <task> <recipe>`
- `bitbake -S printdiff` explains unexpected rebuilds.
- `INHERIT += "rm_work"` saves disk space; `RM_WORK_EXCLUDE` keeps selected work directories.
- `buildhistory` and `buildhistory-diff` track package and image changes.

---
layout: default
---

::title::

Runtime debugging on the target

::body::

- systemd: `systemctl status <service>`, `systemctl cat <service>`, `journalctl -u <service>`, `journalctl -b`
- Kernel and processes: `dmesg`, `dmesg -w`, `strace`, `ltrace`, `perf`, `gdbserver`
- Boot performance: `systemd-analyze`, `systemd-analyze blame`
- Add tools to the image:

```text
IMAGE_INSTALL:append = " strace gdb gdbserver perf"
```

- `devtool deploy-target` for quick iteration on a running target.

---
layout: default
---

::title::

Boot failures

::body::

- The serial console is the first debugging tool: U-Boot and kernel messages.
- QEMU:
  - `runqemu ... serialstdio`
  - `runqemu ... nographic`
- Kernel command line:
  - `earlycon` for early console output
  - `initcall_debug` for driver/initcall debugging
  - `init=/bin/sh` for a shell before init
  - `root=` for the root filesystem
- Pass parameters with `runqemu ... bootparams="earlycon initcall_debug"`.
- systemd emergency shell; inspect `journalctl -b`.
- Check the rootfs mount, init manager and `root=` value.

---
layout: default
---

::title::

Hands-on lab: debugging

::body::

- Lab: `labs/exercises/11-debugging.md`
- Introduce a compile error in `hello.c`, then build and inspect the log:

```bash
cd labs
./kas.sh shell kas/qemu.yml -c 'bitbake hello'
```

- Inspect the environment and reproduce in a devshell:

```bash
bitbake -e hello | grep -E '^(S|B|WORKDIR)='
bitbake -c devshell hello
```

- Check why a task reruns:

```bash
bitbake -S printdiff hello
```

- Debug the systemd service at runtime:

```bash
systemctl status training-service
journalctl -u training-service
```

- Challenge: introduce a checksum failure, find the log and fix it with `devtool`.

---
layout: default
---

::title::

Checkpoint: debugging

::body::

1. Where do you find the log for a failed `do_compile`?
2. What does `bitbake -e` show that `bitbake -c listtasks` does not?
3. What does `bitbake -S printdiff` tell you?
4. How do you force a single task to rerun?
5. Which command shows why a systemd service failed at runtime?
