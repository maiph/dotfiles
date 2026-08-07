#!/usr/bin/env bash

set -e

if ! command -v nvim &>/dev/null; then
    brew install neovim
    exit 0
fi
