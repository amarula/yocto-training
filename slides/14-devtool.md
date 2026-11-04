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

- `devtool` is a collection of tools for working on recipes:
  - `devtool add`
  - `devtool edit-recipe`
  - `devtool upgrade`
  - `devtool finish`
  - `devtool modify`
  - `devtool deploy-target`
  - `devtool undeploy-target`
  - `devtool build`
  - `devtool build-image`
  - `devtool ide-sdk`
  - etc.

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

Yocto devtool some examples

::body::

- `devtool modify gdb`
- Now a workspace is created and you can go inside it. You will find the gdb code.
- Create your git patch using git commands.
- `devtool update-recipe -a sources/meta-w_and_h gdb` and now create the bbappend for your meta layer.
- `devtool reset gdb` (note: the workspace directory must be removed manually).

In the case of a package that is not git, devtool creates a git repository automatically that lets you add your patches. You can easily try using:

```bash
devtool modify connman
```

NOTE: layers play a role here if multiple versions of the package are present.

---
layout: default
---

::title::

Yocto devtool some examples

::body::

- `devtool status` reports your workspace and the project you are working on.
- devtool lets you change code and create patches and bbappends.
- devtool lets us create a new recipe from scratch.
- devtool lets you build:
  - `devtool build connman` and test it.
  - `devtool deploy-target <connection option to copy it>`
- `devtool reset` allows cleaning up the workspace. If this fails because the package added was not well integrated, you can run `devtool reset -n`.
- And devtool lets you create a new build recipe from scratch by guessing the build system. That's the magic, but check now `build/conf/bblayers.conf`: `<your build path>/workspace` is added as an entry.

---
layout: default
---

::title::

Checkpoint: devtool

::body::

1. What does `devtool modify` create, and where?
2. When do you use `devtool update-recipe` versus `devtool update-recipe -a`?
3. How do you clean up the workspace after finishing?
4. Why is editing `tmp/work/` directly discouraged?
