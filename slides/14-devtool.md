---
layout: center
class: text-center
---

# Yocto

## Devtool

---
layout: default
---

::title::

Yocto devtool

::body::

`devtool` is a collection of tools for working on recipes:

- Beginning work: `add`, `modify`, `upgrade`
- Getting information: `status`, `search`, `latest-version`, `check-upgrade-status`
- Working in the workspace: `build`, `build-image`, `edit-recipe`, `find-recipe`, `update-recipe`, `finish`, `reset`
- Testing on target: `deploy-target`, `undeploy-target`
- IDE integration: `ide-sdk`
- Advanced: `menuconfig`, `extract`, `sync`, `export`, `import`, `create-workspace`

---
layout: default
---

::title::

Yocto devtool

::body::

Why do we need devtool?

- Our build system is great for repeatable builds from source.
- Working with the source itself was hard.
- Tempting to just edit sources under `tmp/work/`…
- But the workflow is painful after that (forced builds, manual patch generation, lost work…).
- Help newer users add new software (alongside the regular build and within the eSDK), so recipes, patches, sources, …

---
layout: default
---

::title::

Yocto devtool

::body::

Where can I find documentation resources?

- Yocto Project Reference Manual, `devtool` chapter
- Yocto Project Application Development and the Extensible Software Development Kit (eSDK)
- `devtool --help`
- `devtool <command> --help`

---
layout: default
---

::title::

Yocto devtool

::body::

<div class="grid grid-cols-2 gap-10 items-center">
<div>

`devtool` provides a working workspace:

- A separate environment in which to work on recipes, sources, patches.
- Commands allow moving out of/in the workspace:
  - finish (1)
  - modify, upgrade (2)
  - …

</div>
<div class="flex items-center justify-center gap-4 text-center text-sm">
  <div class="border-2 border-accent rounded p-4">Layers</div>
  <div class="text-xs leading-6">1 finish<br/>2 modify / upgrade</div>
  <div class="border-2 border-accent rounded p-4">devtool<br/>workspace</div>
</div>
</div>

---
layout: default
---

::title::

Yocto devtool

::body::

<div class="grid grid-cols-2 gap-10 items-center">
<div>

`devtool` provides a working workspace:

- build-image (3)
- update-recipe (4)
- deploy-target (5)
- …

</div>
<div class="flex items-center justify-center gap-4 text-center text-sm">
  <div class="border-2 border-accent rounded p-4">devtool<br/>workspace</div>
  <div class="text-xs leading-6">3 build-image<br/>4 update-recipe<br/>5 deploy-target</div>
  <div class="border-2 border-accent rounded p-4">Target</div>
</div>
</div>

---
layout: default
---

::title::

Adding a recipe with devtool

::body::

- Create a recipe from a source tree or a remote URI:

```bash
devtool add https://example.com/hello-1.0.tar.gz
devtool add myhello /path/to/source
devtool add --version 2.1 --srcbranch main --srcrev <sha> \
  https://github.com/example/hello.git
```

- The recipe is created in `workspace/recipes/` and the source in `workspace/sources/`.
- The `workspace` layer is added to `bblayers.conf`.
- Useful options:
  - `-V/--version`, `-S/--srcrev`, `-B/--srcbranch`
  - `-a/--autorev` for a floating revision
  - `-n/--no-extract` when you already have a source tree
  - `--binary` for pre-built files
  - `--also-native` to add a native variant
  - `--src-subdir` for a subdirectory

---
layout: default
---

::title::

Upgrading a recipe with devtool

::body::

- Upgrade an existing recipe:

```bash
devtool upgrade hello
devtool upgrade hello --version 2.0 --srcrev <sha>
```

- The upgraded recipe and source are placed in the workspace.
- Existing patches are applied to the new source; rebase them if needed.
- Options:
  - `--stable` to consider only stable upstream releases
  - `-V/--version`, `-S/--srcrev`, `-B/--srcbranch`
  - `--no-patch` to skip applying existing patches
  - `--keep-failure` to keep the failed upgrade for debugging
- Finish with `devtool finish hello <layer>`.

---
layout: default
---

::title::

Yocto devtool modify recipe

::body::

- For each recipe Yocto creates `tmp/work/<architecture>/<recipe>/<version>`.
- Using the `bitbake` command to force compile or `devshell` is a temptation.
- We should use `devtool`.

How?

---
layout: default
---

::title::

Yocto devtool modify recipe (1 / 3)

::body::

- Run `devtool modify <recipename>`. This will fetch the sources for the recipe and unpack them to a `workspace/sources/<recipename>` directory and initialise it as a git repository if it isn't already one. If you prefer, you can specify your own path, or if you already have your own existing source tree you can specify the path along with the `-n` option to use that instead of unpacking a new one.
- Make the changes you want to make to the source.
- Run a build to test your changes - you can just `bitbake <recipename>` or even build an entire image incorporating the changes, assuming a package produced by the recipe is part of an image. There's no need to force anything - the build system will detect changes to the source and recompile as necessary.

---
layout: default
---

::title::

Yocto devtool modify recipe (2 / 3)

::body::

- If you wish, test your changes on the target. There's a `devtool deploy-target` command which will copy the files installed at `do_install` over to the target machine, assuming it has network access and any dependencies are already present in the image.
- Repeat from step 2 as needed until you're happy with the results.

---
layout: default
---

::title::

Yocto devtool modify recipe (3 / 3)

::body::

- At this point you will almost certainly want to place your changes in the form of a patch to be applied from the metadata - devtool provides help with this as well. Commit your changes using `git commit` (as many or as few commits as you'd like) and then run either:
  - `devtool update-recipe <recipename>` to update the original recipe - usually appropriate if it's your own recipe or you're submitting the changes back to the upstream layer.
  - `devtool update-recipe -a <layerpath> <recipename>` to put your changes in the form of a bbappend to be applied by a different layer. This is usually the desired method if your changes are customisations rather than bugfixes.
- If you're finished working on the recipe, run `devtool reset <recipename>`.

---
layout: default
---

::title::

Finishing a recipe with devtool

::body::

- `devtool finish` pushes committed changes to a layer and removes the recipe from the workspace:

```bash
devtool finish hello meta-training
devtool finish -m patch hello meta-training
devtool finish -m srcrev hello meta-training
```

- Modes:
  - `patch` — source changes as patches
  - `srcrev` — update `SRCREV`
  - `auto` — choose based on the recipe (default)
- Commit changes in the workspace source tree first.
- `--dry-run` reports what would change.
- `--remove-work` cleans the workspace sources.

---
layout: default
---

::title::

Building and deploying with devtool

::body::

- Build the recipe in the workspace:

```bash
devtool build hello
```

- Build an image that includes workspace recipes:

```bash
devtool build-image training-image
```

- Copy the output to a running target:

```bash
devtool deploy-target hello root@192.168.1.10
devtool undeploy-target hello root@192.168.1.10
```

- The target needs network access and the runtime dependencies already installed.

---
layout: default
---

::title::

devtool ide-sdk

::body::

- Generate an IDE configuration for a modified recipe:

```bash
devtool modify hello
devtool ide-sdk hello training-image
```

- Modes:
  - `modified` (default): workspace source, target image and debug configuration
  - `shared`: cross-toolchain and shared sysroot
- `-i code` (default) or `-i none`.
- `-t user@host` configures remote debugging on a running target.
- Requires an image recipe for the target and, for C/C++, a debugger/gdbserver.

---
layout: default
---

::title::

recipetool

::body::

- `recipetool` creates and updates recipes non-interactively:

```bash
recipetool create https://example.com/hello-1.0.tar.gz
recipetool create -o hello_1.0.bb /path/to/source
recipetool newappend meta-training busybox
recipetool appendsrcfile meta-training busybox file://hello.conf
recipetool setvar hello FOO bar
```

- `create` supports tarballs, git, npm, PyPI and more.
- `newappend` creates a `.bbappend` in a layer.
- `appendsrcfile` adds a file to an existing recipe through a `.bbappend`.
- `devtool add` wraps `recipetool create` and manages the workspace.

---
layout: default
---

::title::

Managing the workspace

::body::

- Inspect the workspace:

```bash
devtool status
devtool search <pattern>
devtool latest-version hello
devtool check-upgrade-status
```

- Share or move the workspace:

```bash
devtool export --file workspace.tar
devtool import workspace.tar
```

- Other useful commands:
  - `devtool edit-recipe`, `devtool find-recipe`
  - `devtool menuconfig` for Kconfig-based recipes
  - `devtool extract`, `devtool sync`
  - `devtool reset` to remove a recipe from the workspace

---
layout: default
---

::title::

Hands-on lab: devtool

::body::

- Lab: `labs/exercises/06-devtool.md`
- Start from the lab project:

```bash
cd labs
./kas.sh shell kas/qemu.yml
devtool modify hello
```

- Edit `workspace/sources/hello/hello.c`, then build and test:

```bash
devtool build hello
devtool deploy-target hello root@<target>
```

- Commit the change and finish it into the training layer:

```bash
git -C workspace/sources/hello commit -am "Update hello message"
devtool finish -m patch hello meta-training
```

- Challenge: use `devtool add` to add a new upstream recipe and `devtool upgrade` to update it.

---
layout: default
---

::title::

Checkpoint: devtool

::body::

1. What does `devtool modify` create, and where?
2. When do you use `devtool update-recipe` versus `devtool finish`?
3. What is the difference between `devtool add` and `recipetool create`?
4. Which modes does `devtool finish` support?
5. What does `devtool ide-sdk` require?
