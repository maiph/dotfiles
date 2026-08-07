#!/usr/bin/env bash

set -e

if ! command -v buf &>/dev/null; then
    brew install buf
fi
