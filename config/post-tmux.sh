#!/usr/bin/env bash

set -e

# Install TPM
if [ ! -d ~/.local/share/tmux/tpm ]; then
    echo "Installing TPM (Tmux Plugin Manager)..."
    mkdir -p ~/.local/share/tmux/tpm
    git clone https://github.com/tmux-plugins/tpm $HOME/.local/share/tmux/tpm &>/dev/null
fi

# Install Catppuccin tmux theme
if [ ! -d ~/.local/share/tpm/catppuccin ]; then
    echo "Installing Catppuccin tmux theme..."
    mkdir -p ~/.local/share/tpm/catppuccin
    git clone -b v2.1.3 https://github.com/catppuccin/tmux.git $HOME/.local/share/tpm/catppuccin &>/dev/null
fi

echo "Installing tmux plugins..."
$HOME/.local/share/tmux/tpm/bin/install_plugins &>/dev/null
