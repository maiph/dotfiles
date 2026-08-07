#!/usr/bin/env bash

set -e

if ! command -v gcloud &>/dev/null; then
    brew install python@3.13
    CLOUDSDK_PYTHON=$(which python3)
    brew install --cask gcloud-cli
    exit 0
fi
