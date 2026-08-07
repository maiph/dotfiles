#!/usr/bin/env bash

set -e

if ! command -v yaak &>/dev/null; then
    brew install --cask yaak
    exit 0
fi
