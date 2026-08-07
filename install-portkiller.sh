#!/usr/bin/env bash

set -e

# PortKiller is a native macOS app (installs into /Applications).
if [ "$(uname -s)" != "Darwin" ]; then
    echo "Skipping PortKiller (not macOS)"
    exit 0
fi

if [ ! -d /Applications/PortKiller.app ]; then
    brew install --cask productdevbook/tap/portkiller
    exit 0
fi
