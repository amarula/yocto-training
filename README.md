# Yocto Training

Slidev presentation for the Yocto Training course.

## Requirements

The presentation is built with Node.js and Slidev:

| Component | Requirement |
| --- | --- |
| Node.js | `>= 18.0.0` (tested with Node 22.x) |
| npm | `>= 9` (tested with npm 9.2) |
| Git | required for the theme submodule |
| Chromium (Playwright) | required for `npm run export` and `npm run export:png` |
| Python | `>= 3.9`, only for the KAS labs |

- Slidev is pinned to **51.8.1**, the version the Amarula theme is developed against.
- The theme is a git submodule. Clone with `--recurse-submodules`, or run `git submodule update --init --recursive`.
- `package-lock.json` is committed; use `npm ci` for a reproducible install.
- A Python virtual environment isolates **KAS only**. It does not isolate
  Node.js, npm or the Slidev dependencies, which are installed locally in
  `node_modules`. Use `npm ci` for the slides and, if needed, `nvm`, `fnm` or
  `volta` to select the Node.js version. For full isolation, run the slides in
  a Node container and the labs with `kas-container`.
- For PDF/PNG export, install the Playwright browser and, on Linux, its system dependencies:

```bash
npx playwright install chromium
sudo npx playwright install-deps chromium   # Linux, if system libraries are missing
```

## Setup

```bash
git clone --recurse-submodules <repository-url>
cd yocto-training
npm ci
```

If the repository was cloned without submodules:

```bash
git submodule update --init --recursive
```

## Development

```bash
npm run dev        # live preview
npm run build      # static build in dist/
npm run export     # PDF export
npm run export:png # PNG export
```

## Labs setup (KAS)

The hands-on labs use KAS, which is a Python tool. You can install it with
`pipx` or in a Python virtual environment:

```bash
python3 -m venv .venv
. .venv/bin/activate
pip install kas==5.5
kas --version
```

Alternatively:

```bash
pipx install kas
```

Keep the virtual environment active in the shell where you run the lab
commands:

```bash
cd labs
./kas.sh build kas/qemu.yml
./kas.sh shell kas/qemu.yml -c 'runqemu qemux86-64 training-image'
```

See `labs/README.md` for the exercise index.

## Structure

- `slides.md` — global frontmatter and chapter includes
- `slides/NN-*.md` — one file per chapter
- `public/images/` — images extracted from the original deck
- `source/Yocto Training.odp` — original presentation kept as reference
- `slidev-theme-amarula/` — Amarula Solutions Slidev theme (git submodule)
- `labs/` — hands-on KAS project and exercises; see `labs/README.md`

## License

Slides under Creative Commons license BY-SA 3.0.
