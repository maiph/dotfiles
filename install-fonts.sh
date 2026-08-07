#!/usr/bin/env bash

set -e

if ! $(brew list --cask font-jetbrains-mono) &>/dev/null; then
    brew install --cask font-jetbrains-mono
fi
