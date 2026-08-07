#!/usr/bin/env bash

set -e

if ! command -v sdk &>/dev/null; then
    brew tap sdkman/tap
    brew install sdkman-cli
fi

SDKMAN_DIR=$(brew --prefix sdkman-cli)/libexec

sed -i 's/sdkman_auto_complete=false/sdkman_auto_complete=${sdkman_auto_complete:-true}/g' $SDKMAN_DIR/etc/config

# Install SDKs using SDKMAN
# source "$(brew --prefix sdkman-cli)/libexec/bin/sdkman-init.sh"
# sdk install java 25.0.1-tem
# sdk install gradle
