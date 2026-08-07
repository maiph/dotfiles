#!/usr/bin/env bash

set -e

if ! command -v witr &>/dev/null; then
    brew install witr
    exit 0
fi
