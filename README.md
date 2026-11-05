# schapiro.org homepage

The Schapiro Center homepage at <https://www.schapiro.org/>: a small [Hugo](https://gohugo.io/)
site deployed to Cloudflare Workers static assets by Cloudflare Workers Builds.

## Editing

- **Link cards:** [`data/links.yaml`](data/links.yaml) holds the three sections (Personal
  Homepages, Memorial Homepages, See Also). Card images live in `static/`, about 233 px wide.
  Entries in sections marked `structured: true` are also listed in the home page's `WebSite`
  structured data (`hasPart`).
- **Intro text:** `content/_index.md`
- **Impressum & Datenschutz:** `content/impressum/index.html`: the privacy-notice generator's HTML
  output, kept as HTML. To update, replace everything below the front matter with the new output.
  Its figures sit next to it.
- **Upload page** for event photos: `content/upload.md`, served at `/upload/`, noindex
- **Redirects:** `static/_redirects` ([format](https://developers.cloudflare.com/workers/static-assets/redirects/))
- **Page `<head>`** (title, description, link previews, icons, structured data):
  `layouts/partials/head.html`
- **Styles:** `static/style.css`

## Local development

Install Hugo (`brew install hugo`), then:

```bash
./run.sh
```

opens a live-reloading server on <http://localhost:1313>. `./build.sh` builds into `public/`
(`./build.sh -p` for a production build; all other builds are `noindex`).

## Deployment

[`wrangler.jsonc`](wrangler.jsonc) is the source of truth for the deploy: Worker name, custom
domains (`www.schapiro.org`, `schapiro.org`) and static asset handling.
[`bin/ci-build.sh`](bin/ci-build.sh) installs the latest Hugo release (checksum-verified) and
runs `./build.sh`; only `main` gets a production build.

Hugo is deliberately not pinned. To pin it, set the build variable `HUGO_VERSION` (e.g. `0.169.0`).

### Cloudflare dashboard settings

The Workers project `schapiro-org-homepage` is connected to this repository. Its build
settings (Settings → Build) can't live in this repo:

- **Build command:** `./bin/ci-build.sh`
- **Deploy command:** `npx wrangler deploy`
- **Non-production branch deploy command:** `npx wrangler versions upload`
  (uploads a preview version and posts its URL on the PR; it never touches production)
- **Production branch:** `main`, **builds for non-production branches:** on
