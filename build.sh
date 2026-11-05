#!/usr/bin/env bash
# Builds the site into public/. -p = production build (indexable by search engines).
set -euo pipefail
cd "$(dirname "${BASH_SOURCE[0]}")"
command -v hugo >/dev/null || { echo "hugo is required (install hint: brew install hugo)" >&2; exit 1; }

environment=development
[[ "${1:-}" == "-p" ]] && environment=production
exec hugo build --cleanDestinationDir --gc --minify --environment "$environment"
