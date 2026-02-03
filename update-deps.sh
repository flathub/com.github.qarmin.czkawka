#!/usr/bin/env bash

set -euo pipefail

# set this to the git release tag
TARGET_VERSION="10.0.0_flatpak"

LOCK_FILE_DIR=$(mktemp -d)
cleanup() {
  rm -r "$LOCK_FILE_DIR"
}
trap cleanup EXIT
set -x

# TAG
#curl -s -L "https://github.com/qarmin/czkawka/archive/refs/tags/$TARGET_VERSION.tar.gz" | tar xzf - -C "$LOCK_FILE_DIR"
# BRANCH
# unzip does not accept zip archive on stdin, so download to a temporary file then extract.
ZIP_FILE="$LOCK_FILE_DIR/archive.zip"
curl -s -L -o "$ZIP_FILE" "https://github.com/qarmin/czkawka/archive/refs/heads/$TARGET_VERSION.zip"
if command -v unzip >/dev/null 2>&1; then
  unzip -q -d "$LOCK_FILE_DIR" "$ZIP_FILE"
else
  # Fallback: use Python's zipfile module to extract if unzip isn't available
  python3 -c "import zipfile; zipfile.ZipFile('$ZIP_FILE').extractall('$LOCK_FILE_DIR')"
fi

# Mount current directory as /tmp/build in container
# download flatpak-cargo-generator and it's dependencies
# refreshes cargo-sources.json
podman run --rm -it \
  -v .:/tmp/build:Z \
  -v "$LOCK_FILE_DIR:$LOCK_FILE_DIR:Z" \
  --pull newer \
  docker.io/library/python:latest \
  sh -c "mkdir -p /tmp/build/flatpak-builder-tools && \
  curl -o /tmp/build/flatpak-builder-tools/flatpak-cargo-generator.py https://raw.githubusercontent.com/flatpak/flatpak-builder-tools/refs/heads/master/cargo/flatpak-cargo-generator.py && \
  pip install --root-user-action=ignore aiohttp toml tomlkit && \
  python3 /tmp/build/flatpak-builder-tools/flatpak-cargo-generator.py ${LOCK_FILE_DIR}/czkawka-${TARGET_VERSION}/Cargo.lock -o /tmp/build/cargo-sources.json"
