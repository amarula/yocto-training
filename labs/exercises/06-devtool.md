# Lab 06 — Devtool

## Goal

Modify the `hello` source with `devtool`, build it, and finish the change as a
patch in the training layer.

## Start a workspace

From the `labs/` directory:

```bash
./kas.sh shell kas/qemu.yml
devtool modify hello
devtool status
```

The source is extracted to `workspace/sources/hello/`, and a `hello` entry is
added to the devtool workspace layer.

## Change and build

Edit the message in `workspace/sources/hello/hello.c`, for example:

```bash
sed -i 's/Hello from the Yocto training image!/Hello from devtool!/' \
  workspace/sources/hello/hello.c
```

Build the recipe:

```bash
devtool build hello
```

## Commit and finish

Commit the change in the workspace git repository:

```bash
git -C workspace/sources/hello commit -am "Update hello message"
```

Finish the recipe into the training layer as a patch:

```bash
devtool finish -m patch hello meta-training
devtool status
```

Inspect the generated patch and the updated recipe or bbappend:

```bash
ls meta-training/recipes-apps/hello/
ls meta-training/recipes-apps/hello/files/
```

## Rebuild and verify

```bash
./kas.sh build kas/qemu.yml
./kas.sh shell kas/qemu.yml -c 'runqemu qemux86-64 training-image'
hello
```

The output should now be `Hello from devtool!`.

## Challenge — devtool add

Add a new recipe from a local source tree or a tarball:

```bash
devtool add --version 1.0 /path/to/source
devtool build <recipe>
devtool finish <recipe> meta-training
```

## Challenge — devtool upgrade

Upgrade an existing recipe to a newer version:

```bash
devtool upgrade <recipe> --version <new-version>
```

Rebase any patches, build, and finish it into the layer.

## Validation

```bash
./scripts/check-lab.sh
```
