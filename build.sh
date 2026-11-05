#!/usr/bin/env bash
# Builds the site into public/. Used locally and as the Cloudflare Workers Builds
# build command. Only production builds are indexable by search engines: main on
# Cloudflare (WORKERS_CI_BRANCH=main) or ./build.sh -p locally.
set -euo pipefail
cd "$(dirname "${BASH_SOURCE[0]}")"

environment=development
if [[ "${1:-}" == "-p" || "${WORKERS_CI_BRANCH:-}" == "main" ]]; then
  environment=production
fi
exec hugo build --cleanDestinationDir --gc --minify --environment "$environment"
