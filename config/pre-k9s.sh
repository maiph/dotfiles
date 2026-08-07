#!/usr/bin/env bash

set -e

if ! command -v k9s &>/dev/null; then
    brew install derailed/k9s/k9s
    exit 0
fi
