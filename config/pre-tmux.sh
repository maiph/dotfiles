#!/usr/bin/env bash

set -e

if ! command -v tmux &>/dev/null; then
    brew install tmux
    exit 0
fi
