#!/usr/bin/env bash

set -e

if [ ! -f "${ZDOTDIR:-$HOME}/.zshenv" ]; then
    echo "Creating ${HOME}/.zshenv to set ZDOTDIR"
cat > "${HOME}/.zshenv" <<EOF
ZDOTDIR=\$HOME/.config/zsh
. \$ZDOTDIR/.zshenv
EOF
fi
