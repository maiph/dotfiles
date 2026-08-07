#!/usr/bin/env bash

set -e

# Skip the Homebrew cask install when not on macOS (Ghostty config is
# still linked below, so only the installer is skipped).
if [ "$(uname -s)" != "Darwin" ]; then
    echo "Skipping Ghostty cask install (not macOS)"
    exit 0
fi

if ! command -v ghostty &>/dev/null; then
    brew install --cask ghostty
    exit 0
fi
