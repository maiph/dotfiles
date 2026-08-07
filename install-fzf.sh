#!/usr/bin/env bash

set -e

if ! command -v fzf &>/dev/null; then
    brew install fzf
    exit 0
fi
