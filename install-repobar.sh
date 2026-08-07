#!/usr/bin/env bash

set -e

# RepoBar is a native macOS app (installs into /Applications).
if [ "$(uname -s)" != "Darwin" ]; then
    echo "Skipping RepoBar (not macOS)"
    exit 0
fi

if [ ! -d /Applications/RepoBar.app ]; then
    brew install --cask steipete/tap/repobar
    exit 0
fi
