# schapiro.org homepage

The Schapiro Center homepage at <https://schapiro.org/>: a small [Hugo](https://gohugo.io/)
site deployed to Cloudflare Workers static assets by Cloudflare Workers Builds.

## Editing

- **Link cards:** [`data/links.yaml`](data/links.yaml) holds the three sections (Personal
  Homepages, Memorial Homepages, See Also). Card images live in `assets/images/`, about 233 px wide.
  Entries in sections marked `structured: true` are also listed in the home page's `WebSite`
  structured data (`hasPart`).
- **Intro text:** `content/_index.md`
- **Impressum & Datenschutz:** `content/impressum/index.html`: the privacy-notice generator's HTML
  output, kept as HTML. To update, replace everything below the front matter with the new output.
  Its figures sit next to it.
- **404 page:** `content/404.md`
- **Upload page** for event photos: `content/upload.md`, served at `/upload/`, noindex
- **Redirects:** `static/_redirects` ([format](https://developers.cloudflare.com/workers/static-assets/redirects/)); **robots.txt:** `static/robots.txt`
- **Page `<head>`** (title, description, link previews, icons, structured data):
  `layouts/_partials/head.html`
- **Styles:** `assets/css/style.css` (plain CSS with native nesting, system fonts; inlined into each page)
- **Images:** `assets/images/`. Hugo serves them content-hashed; card photos and the logo are
  resized and converted to WebP. All are cached for a year (`static/_headers`). `static/` holds only files that
  need a fixed name: favicons, `robots.txt`, `_redirects`, `_headers`.

Templates: `layouts/baseof.html` wraps every page (head, logo, footer); `layouts/home.html` renders
the home page with the link cards; `layouts/page.html` renders every other page from `content/`.

## Local development

Install Hugo (`brew install hugo`), then run `hugo server` for a live-reloading preview on
<http://localhost:1313>. `./build.sh` builds into `public/` (`./build.sh -p` for an indexable
production build; all other builds are `noindex`).

## Deployment

Cloudflare Workers Builds runs `./build.sh` and deploys `public/` as Workers static assets.
[`wrangler.jsonc`](wrangler.jsonc) is the source of truth for the deploy: Worker name, custom
domains and 404 handling. `schapiro.org` and `www.schapiro.org` both serve the site; the apex is
canonical (`<link rel="canonical">` on every page), `www` is not redirected. Only `main` gets an indexable
production build.

### Cloudflare dashboard settings

The Workers project `schapiro-org-homepage` is connected to this repository. These settings
can't live in this repo:

- **Build command:** `./build.sh`
- **Deploy command:** `npx wrangler deploy`
- **Preview command:** `npx wrangler versions upload`
  (uploads a preview version and posts its URL on the PR; it never touches production)
- **Production branch:** `main`, **Enable Preview builds:** on
- **Build variable:** `HUGO_VERSION` = `0.169.0`. Cloudflare's build image installs this Hugo
  version; bump it here when you upgrade Hugo locally.
