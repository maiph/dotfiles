#!/usr/bin/env bash

set -e

if ! command -v uvx &>/dev/null; then
    brew install uv
fi

if ! command -v claude &>/dev/null; then
    brew install --cask claude-code@latest
fi
