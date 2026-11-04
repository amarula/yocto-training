# Yocto Training

Slidev presentation for the Yocto Training course.

## Setup

```bash
git clone --recurse-submodules <repository-url>
cd yocto-training
npm install
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

## Structure

- `slides.md` — global frontmatter and chapter includes
- `slides/NN-*.md` — one file per chapter
- `public/images/` — images extracted from the original deck
- `source/Yocto Training.odp` — original presentation kept as reference
- `slidev-theme-amarula/` — Amarula Solutions Slidev theme (git submodule)

## License

Slides under Creative Commons license BY-SA 3.0.
