#!/usr/bin/env bash
# Local development server with live reload on http://localhost:1313
set -euo pipefail
cd "$(dirname "${BASH_SOURCE[0]}")"
command -v hugo >/dev/null || { echo "hugo is required (install hint: brew install hugo)" >&2; exit 1; }
exec hugo server "$@"
