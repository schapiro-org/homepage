#!/usr/bin/env bash
# CI-only entry point for Cloudflare Workers Builds (build command: ./bin/ci-build.sh).
#
# Installs the LATEST Hugo release into the repo-local .cache/bin, verified
# against Hugo's official checksums file, then runs ./build.sh. Hugo is not
# pinned on purpose: this site uses only basic Hugo features. To pin anyway,
# set HUGO_VERSION (e.g. 0.169.0) as a build variable in the Cloudflare dashboard.
#
# Laptops don't use this: install Hugo yourself (brew install hugo) and run ./build.sh.
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
install_dir="$repo_root/.cache/bin"
work_dir="$(mktemp -d)"
trap 'rm -rf "$work_dir"' EXIT

case "$(uname -m)" in
  x86_64 | amd64) arch=amd64 ;;
  aarch64 | arm64) arch=arm64 ;;
  *) echo "unsupported architecture: $(uname -m)" >&2; exit 1 ;;
esac

# Candidate versions, newest first. git ls-remote needs no GitHub API token and
# has no API rate limit. Fall back to older releases in case the newest tag
# exists before its release files are uploaded.
if [[ -n "${HUGO_VERSION:-}" ]]; then
  candidates=("$HUGO_VERSION")
else
  mapfile -t candidates < <(git ls-remote --tags --refs https://github.com/gohugoio/hugo.git 'v*' |
    sed -n 's#.*refs/tags/v\([0-9]*\.[0-9]*\.[0-9]*\)$#\1#p' | sort -V -r | head -3)
fi
[[ ${#candidates[@]} -gt 0 ]] || { echo "could not determine a Hugo version" >&2; exit 1; }

install_hugo() {
  local version="$1" asset url
  asset="hugo_${version}_linux-${arch}.tar.gz"
  url="https://github.com/gohugoio/hugo/releases/download/v${version}"
  curl -fsSL -o "$work_dir/checksums.txt" "$url/hugo_${version}_checksums.txt" || return 1
  curl -fsSL -o "$work_dir/$asset" "$url/$asset" || return 1
  (cd "$work_dir" && grep " ${asset}\$" checksums.txt | sha256sum -c -) || {
    echo "checksum verification failed for $asset" >&2
    exit 1
  }
  tar -xzf "$work_dir/$asset" -C "$work_dir" hugo
  mkdir -p "$install_dir"
  install -m 755 "$work_dir/hugo" "$install_dir/hugo"
}

for version in "${candidates[@]}"; do
  if install_hugo "$version"; then
    break
  fi
  echo "Hugo $version not downloadable, trying the previous release" >&2
done
[[ -x "$install_dir/hugo" ]] || { echo "Hugo installation failed" >&2; exit 1; }
export PATH="$install_dir:$PATH"
hugo version

# Workers Builds sets WORKERS_CI_BRANCH. Only main gets an indexable production
# build; all other branches (PR previews) are built with noindex.
if [[ "${WORKERS_CI_BRANCH:-}" == "main" ]]; then
  exec "$repo_root/build.sh" -p
else
  exec "$repo_root/build.sh"
fi
