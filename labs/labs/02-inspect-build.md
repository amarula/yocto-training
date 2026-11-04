# Lab 02 — Inspect the build

## Goal

Explore the build directory, metadata and task graph without changing the
image.

## Enter the build environment

```bash
./kas.sh shell kas/qemu.yml
```

Inside the shell:

```bash
bitbake-layers show-layers
bitbake-layers show-recipes 'hello*'
bitbake-layers show-recipes 'training-image'
```

## Inspect variables

```bash
bitbake -e hello | grep -E '^(PN|PV|S|WORKDIR|UNPACKDIR|D)='
```

Questions:

- Where is the source unpacked?
- What is the difference between `WORKDIR`, `UNPACKDIR` and `S`?
- Where does the recipe install files into (`D`)?

## Inspect tasks

```bash
bitbake -c listtasks hello
```

Identify `do_fetch`, `do_unpack`, `do_compile`, `do_install` and `do_package`.

## Inspect the dependency graph

```bash
bitbake -g training-image
ls -l task-depends.dot pn-buildlist
```

Open `task-depends.dot` with a text editor, or convert it to SVG:

```bash
dot -Tsvg task-depends.dot -o task-depends.svg
```

## Find the work directory

```bash
find build/tmp/work -maxdepth 4 -type d -name 'hello-1.0*'
```

Inspect the `temp/` directory inside it:

```bash
ls build/tmp/work/*/hello/1.0*/temp/
```

The `log.do_compile` and `log.do_install` files are the first place to look
when a build fails.

## Challenge

Run `bitbake -g -u taskexp training-image` and find the tasks that produce the
`hello` package. Which task must run before `do_rootfs`?
