#!/usr/bin/env bash

set -e

if [ ! -d /Applications/RepoBar.app ]; then
    brew install --cask steipete/tap/repobar
    exit 0
fi
