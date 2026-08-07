#!/usr/bin/env bash

set -e

if [ ! -d /Applications/PortKiller.app ]; then
    brew install --cask productdevbook/tap/portkiller
    exit 0
fi
