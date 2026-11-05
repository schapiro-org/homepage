# AGENTS.md

Instructions for AI coding agents working on this repository. Read `README.md` for the
editing/deploy overview; this file is about keeping the site intact.

## What this is

The Schapiro Center homepage, <https://schapiro.org/>: one page of link cards to the family's
homepages, plus Impressum, an upload page and a 404 page. Hugo static site, built and deployed by
Cloudflare Workers Builds. Small on purpose: plain HTML/CSS, no JavaScript, no web fonts, no
dependencies besides Hugo.

## Map

| What | Where |
|---|---|
| Link cards (3 sections) | `data/links.yaml` |
| Color palette | `[params.colors]` in `hugo.toml` |
| Page shell (header, footer) | `layouts/baseof.html` |
| Home page / all other pages | `layouts/home.html` / `layouts/page.html` |
| `<head>`: meta, link previews, icons, JSON-LD, inlined CSS | `layouts/_partials/head.html` |
| Link-preview image (generated) | `layouts/_partials/og-image.html` |
| Markdown links / images | `layouts/_markup/render-link.html`, `render-image.html` |
| Styles | `assets/css/style.css` |
| Images (content-hashed on build) | `assets/images/` |
| Files that need a fixed URL | `static/` (favicons, `robots.txt`, `_redirects`, `_headers`) |
| Deploy config | `wrangler.jsonc`; dashboard settings are listed in `README.md` |

## Rules: don't break these

1. **One source per fact.** Colors live only in `[params.colors]` (`hugo.toml`); never hard-code a
   color in CSS or templates. The family list lives only in `data/links.yaml`; the cards, the
   `WebSite.hasPart` JSON-LD and the link-preview image are all generated from it.
2. **Hugo lowercases parameter keys.** Name new keys in lowercase (use hyphens, like the CSS
   variables: `text-light`), or they won't match.
3. **No web fonts, no external requests.** Text uses the system font stacks `--font-serif` /
   `--font-sans` in `style.css`. A font download costs speed and, from Google Fonts, violates
   DSGVO. `assets/fonts/` is only for drawing text into the preview image at build time.
4. **Everything referenced from templates goes through `assets/`** so it gets a content-hashed
   name (cached for a year via `static/_headers`). Put a file in `static/` only if its URL must
   never change.
5. **Images:** card photos are cropped 3:4 with anchor `Center` (not `Smart`: it shifts the frame
   even for 3:4 sources) and converted to WebP at 2x display size. Logos (`padded: true`) are only
   ever scaled down, never cropped or upscaled. Keep `width`/`height` on every `<img>`.
6. **Indexing:** only the production build of `main` is indexable. `build.sh` decides via
   `WORKERS_CI_BRANCH`; every other build (PR previews, local) gets `noindex`. The upload page is
   always `noindex`, not in the sitemap and not in `robots.txt`.
7. **Canonical host is `https://schapiro.org/`** (`baseURL`). `www.schapiro.org` serves the same
   site without a redirect; the canonical link handles search engines.
8. **Impressum** (`content/impressum/index.html`) is the HTML output of the privacy-notice
   generator. Don't convert or reformat it; updates replace everything below the front matter.
   That's why `hugo.toml` allows `.html` content (`[security] allowContent`).
9. **Redirects** in `static/_redirects` always state `301` explicitly (Cloudflare defaults to 302).
10. **Performance target:** first load under 1 s. Lighthouse Performance is 100. Don't add
    render-blocking requests, JavaScript or large images.

## Verify a change

```bash
./build.sh -p          # production build into public/, must print no ERROR or WARN
hugo server            # live preview on http://localhost:1313
```

Then check in `public/`: `index.html` has 3 `<h2>` sections and one card per entry in
`data/links.yaml`; the home page has no `noindex` (in a `-p` build); `images/og-image.*.jpg` is
1200x630 and shows every personal and memorial portrait. Every PR gets a Cloudflare preview
URL (posted on the PR); look at it before merging.
