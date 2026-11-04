# Lab 11 — Debugging

## Goal

Diagnose a compile failure, inspect the build environment and task
signatures, and debug a service at runtime.

## Part 1 — Break and fix a compile

Introduce a syntax error in
`meta-training/recipes-apps/hello/files/hello.c`, for example remove a
semicolon.

Build the recipe:

```bash
cd labs
./kas.sh shell kas/qemu.yml -c 'bitbake hello'
```

Find the task log:

```bash
find build/tmp/work -path '*hello*' -name 'log.do_compile' | head
```

Read the compiler error, fix `hello.c`, and rebuild:

```bash
./kas.sh shell kas/qemu.yml -c 'bitbake hello'
```

## Part 2 — Inspect the environment and devshell

```bash
./kas.sh shell kas/qemu.yml -c \
  "bitbake -e hello | grep -E '^(S|B|WORKDIR|D)='"
```

Open a devshell and reproduce the build manually:

```bash
./kas.sh shell kas/qemu.yml -c 'bitbake -c devshell hello'
```

Inside the shell, inspect `$S`, `$B` and `$D`, then run the compiler command
from the log.

## Part 3 — Why did it rebuild?

```bash
./kas.sh shell kas/qemu.yml -c 'bitbake -S printdiff hello'
```

Look for the variable or file that changed. Try touching `hello.c` and compare
the result.

## Part 4 — Debug the service at runtime

```bash
./kas.sh build kas/qemu.yml
./kas.sh shell kas/qemu.yml -c 'runqemu qemux86-64 training-image'
```

On the target:

```bash
systemctl status training-service
journalctl -u training-service -n 20
systemctl cat training-service
```

Stop the service, break its `ExecStart`, and observe the failure:

```bash
systemctl stop training-service
systemctl status training-service
journalctl -u training-service -n 50
```

## Part 5 — Boot parameters

Run QEMU with extra kernel parameters:

```bash
./kas.sh shell kas/qemu.yml -c \
  'runqemu qemux86-64 training-image bootparams="earlycon initcall_debug"'
```

Look for the extra kernel messages in the console output.

## Challenge — checksum failure

Add a missing local file to `SRC_URI` in `hello_1.0.bb`, build `hello`, and
find the failure in `log.do_fetch` or `log.do_unpack`. Remove the entry and
rebuild.

## Cleanup

Revert the lab changes before continuing:

```bash
git status
git checkout -- meta-training/recipes-apps/hello/files/hello.c
```

Use `git diff` to confirm the tree is clean.

## Validation

```bash
./scripts/check-lab.sh
```
