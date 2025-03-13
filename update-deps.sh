#!/usr/bin/env bash

set -euo pipefail

# set this to the git release tag
TARGET_VERSION="8.0.0"

LOCK_FILE_DIR=$(mktemp -d)
cleanup() {
  rm -r "$LOCK_FILE_DIR"
}
trap cleanup EXIT
set -x

curl -s -L "https://github.com/qarmin/czkawka/archive/refs/tags/$TARGET_VERSION.tar.gz" | tar xzf - -C "$LOCK_FILE_DIR"

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
  pip install --root-user-action=ignore aiohttp toml && \
  python3 /tmp/build/flatpak-builder-tools/flatpak-cargo-generator.py ${LOCK_FILE_DIR}/czkawka-${TARGET_VERSION}/Cargo.lock -o /tmp/build/cargo-sources.json"
