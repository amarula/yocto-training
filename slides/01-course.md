---
layout: cover
---

---
layout: default
---

::title::

Amarula Solutions Company

::body::

<div class="grid grid-cols-2 gap-8 items-center">
<div>

In Amarula Solutions, we design software that powers real products in the real world! We are not a PoC company. We take dreams, and we make them real, using our experience to drive our customers on choices and anticipate/avoid future issues on the field.

See what we have done in the market. One day, a million of devices and a thousand of companies will use our software. This is going to be true for industrial products and open source software.

</div>
<div>

<img src="/images/amarula-team.png" class="max-h-80 mx-auto rounded" alt="Amarula Solutions team" />

</div>
</div>

---
layout: center
class: text-center
---

# Course

## Preliminary

---
layout: default
---

::title::

Course structure

::body::

- **Foundations**: Linux boot, embedded Linux distros, Yocto fundamentals, OE-Core and KAS
- **Metadata**: variables and overrides, BitBake, recipes, classes, layers
- **Images and integration**: images, WIC, devtool, SDK
- **Releases and compliance**: license/SBOM, reproducible KAS/CI builds

Each block ends with a lab and a checkpoint. The hands-on project lives in `labs/`.

Suggested timing: 5 days — 4 core days plus 1 day for the capstone and advanced modules.

---
layout: default
---

::title::

Goals of training

::body::

- An introduction to Operating system packaging tools
- Yocto architecture
- How to proficiently operate using Yocto
- Create and maintain your project

---
layout: default
---

::title::

Prerequisites and outcomes

::body::

<div class="grid grid-cols-2 gap-8">

<div>

### Assumed knowledge

- Linux command line and git
- C programming
- Embedded Linux basics: bootloader, kernel, root filesystem

</div>

<div>

### By the end you will be able to

- Build and boot a Yocto image with KAS
- Read and write recipes, classes and bbappends
- Create a layer and a BSP machine
- Customize images with packages, WIC and kernel fragments
- Use devtool and the SDK
- Produce license/SBOM reports and a reproducible release

</div>

</div>

---
layout: default
---

::title::

Embedded board of this training

::body::

<img src="/images/engicam-board-kit.png" class="max-h-96 mx-auto" alt="Engicam i.Core MX8M Plus board kit" />

---
layout: default
---

::title::

Rules of participation

::body::

- Ask any questions you like connected with the topic. Don't ask on feature topic
- Ask questions to compare with your experience with other systems
- Point of view is important because can be a plus to everyone and to the trainer
- Raise your hands before asking questions

---
layout: default
---

::title::

Questions in Mattermost

::body::

- We encourage you to subscribe to the Mattermost channel for this training
- Subscribe to the channel lets us and you stay in contact with us
- Help you to raise questions that can be useful for the trainer and participants
- It's free for 2 months

---
layout: default
---

::title::

Training setup

::body::

- Send your git public key to get access to the workspace
- Provide the email to register to the Mattermost channel

During the training, it will be possible to access an external disk or to have interaction and communication with the teacher for a period of time.

---
layout: default
---

::title::

Labs and checkpoints

::body::

- The hands-on project is in `labs/` in the training repository.
- Each block ends with a short checkpoint (three questions) and a lab.
- The first exercises are `labs/exercises/00-setup.md`, `01-build-and-run.md` and `02-inspect-build.md`.
- The capstone combines a custom recipe, layer, systemd service, kernel fragment, WIC image, SDK and a locked KAS release.

```bash
cd labs
./kas.sh build kas/qemu.yml
./kas.sh shell kas/qemu.yml -c 'runqemu qemux86-64 training-image'
```

See `labs/README.md` for the full exercise index.
