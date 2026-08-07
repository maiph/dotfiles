#!/usr/bin/env bash

set -e

if ! command -v ghostty &>/dev/null; then
    brew install --cask ghostty
    exit 0
fi
