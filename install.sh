#!/usr/bin/env bash

# Load this to get some environment variables set up
source ./config/zsh/.zshenv >/dev/null 2>&1

install_scripts() {
    if [ ! -d ~/.local/bin ]; then
        mkdir -p ~/.local/bin
    fi

    for f in ./scripts/*; do
        echo "Installing script: $f"
        ln -sfn "$(realpath "$f")" "$HOME/.local/bin/$(basename "$f")"
    done
}

mk_dirs() {
    if [ ! -d ~/.local/share ]; then
        mkdir -p ~/.local/share
    fi

    if [ ! -d ~/.local/share/zsh/completions ]; then
        mkdir -p ~/.local/share/zsh/completions
    fi
}

install_scripts
mk_dirs

for f in ./install-*.sh; do
    echo "Running: $f"
    $f &>/dev/null
    if [ $? -ne 0 ]; then
        echo -e "\tError running $f"
    fi
done

for d in ./config/*/; do
    name="$(basename "$d")"
    target="$HOME/.config/$name"
    pre_script="./config/pre-$name.sh"
    post_script="./config/post-$name.sh"

    echo "Processing config directory: $d"

    # Run pre-script if it exists
    if [ -f "$pre_script" ]; then
        # echo "Running pre-script: $pre_script"
        bash "$pre_script"
    fi

    # echo "Linking $d -> $target"
    ln -sfn "$(realpath "$d")" "$target"

    # Run post-script if it exists
    if [ -f "$post_script" ]; then
        # echo "Running post-script: $post_script"
        bash "$post_script"
    fi
done
