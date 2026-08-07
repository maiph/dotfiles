#!/usr/bin/env bash

# ---------- Homebrew ----------

# Locate an existing Homebrew installation across macOS and Linux prefixes.
find_brew_prefix() {
    local prefix
    for prefix in \
        /opt/homebrew \
        /usr/local \
        /home/linuxbrew/.linuxbrew \
        "${HOME}/.linuxbrew" \
        "${HOME}/homebrew"; do
        if [ -x "${prefix}/bin/brew" ]; then
            printf '%s\n' "${prefix}"
            return 0
        fi
    done
    return 1
}

# Install the system build tools Homebrew-on-Linux requires (armed for the
# common Linux package managers; mirrors https://docs.brew.sh/Homebrew-on-Linux).
install_linux_build_deps() {
    if command -v apt-get >/dev/null 2>&1; then
        echo "Ensuring Homebrew build prerequisites (apt)..."
        sudo apt-get update
        sudo apt-get install -y build-essential procps curl file git
    elif command -v dnf >/dev/null 2>&1; then
        echo "Ensuring Homebrew build prerequisites (dnf)..."
        sudo dnf group install -y development-tools
        sudo dnf install -y procps-ng curl file
    elif command -v pacman >/dev/null 2>&1; then
        echo "Ensuring Homebrew build prerequisites (pacman)..."
        sudo pacman -S --needed --noconfirm base-devel procps-ng curl file git
    fi
}

# Install Homebrew if not already present. Aborts the dotfiles setup if the
# installation fails, since nearly everything below depends on brew.
ensure_homebrew() {
    local prefix
    if prefix="$(find_brew_prefix)"; then
        echo "Homebrew already installed at ${prefix}"
    elif [ "$(uname -s)" = "Darwin" ]; then
        echo "Installing Homebrew (macOS)..."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    else
        echo "Installing Homebrew (Linux)..."
        install_linux_build_deps
        NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    fi

    if ! prefix="$(find_brew_prefix)"; then
        echo "ERROR: Homebrew is required but could not be installed." >&2
        exit 1
    fi

    HOMEBREW_PREFIX="${prefix}"
    export HOMEBREW_PREFIX
    # Put brew on PATH for the remainder of this script.
    eval "$("${prefix}/bin/brew" shellenv)"
}

ensure_homebrew

# Load this to get some environment variables set up.
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
