#!/usr/bin/env bash

failures=0

run_step() {
    local description="$1" status
    shift
    if "$@"; then
        return 0
    else
        status=$?
        printf 'ERROR: %s failed (exit %s)\n' "$description" "$status" >&2
        failures=$((failures + 1))
        return "$status"
    fi
}

# ---------- Homebrew ----------

find_homebrew() {
    local candidate
    if command -v brew; then
        return 0
    fi

    for candidate in \
        /opt/homebrew/bin/brew \
        /usr/local/bin/brew \
        /home/linuxbrew/.linuxbrew/bin/brew \
        "$HOME/.linuxbrew/bin/brew"; do
        if [ -x "$candidate" ]; then
            printf '%s\n' "$candidate"
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
        sudo apt-get update || return $?
        sudo apt-get install -y build-essential procps curl file git || return $?
    elif command -v dnf >/dev/null 2>&1; then
        echo "Ensuring Homebrew build prerequisites (dnf)..."
        sudo dnf group install -y development-tools || return $?
        sudo dnf install -y procps-ng curl file || return $?
    elif command -v pacman >/dev/null 2>&1; then
        echo "Ensuring Homebrew build prerequisites (pacman)..."
        sudo pacman -S --needed --noconfirm base-devel procps-ng curl file git || return $?
    fi
}

# Install Homebrew if not already present. Aborts the dotfiles setup if the
# installation fails, since nearly everything below depends on brew.
ensure_homebrew() {
    local brew installer shellenv
    if brew="$(find_homebrew)"; then
        echo "Homebrew already installed at ${brew}"
    else
        case "$(uname -s)" in
            Darwin)
                echo "Installing Homebrew (macOS)..."
                installer="$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)" || return $?
                /bin/bash -c "$installer" || return $?
                ;;
            Linux)
                echo "Installing Homebrew (Linux)..."
                install_linux_build_deps || return $?
                installer="$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)" || return $?
                NONINTERACTIVE=1 /bin/bash -c "$installer" || return $?
                ;;
            *)
                echo "ERROR: Unsupported operating system: $(uname -s)" >&2
                return 1
                ;;
        esac
    fi

    if ! brew="$(find_homebrew)"; then
        echo "ERROR: Homebrew is required but could not be installed." >&2
        return 1
    fi

    shellenv="$("${brew}" shellenv)" || return $?
    eval "$shellenv"
}

run_step "Homebrew setup" ensure_homebrew || exit 1

# Load this to get some environment variables set up.
run_step "Environment setup" source ./config/zsh/.zshenv >/dev/null 2>&1 || {
    echo "ERROR: Could not load the dotfiles environment" >&2
    exit 1
}

link_path() {
    local source_path target="$2" backup=""
    source_path="$(realpath "$1")" || return $?

    mkdir -p "$(dirname "$target")" || return $?
    if [ -L "$target" ] && [ "$(readlink "$target")" = "$source_path" ]; then
        return 0
    fi

    # Preserve files, real directories, and conflicting (even dangling) links.
    if [ -e "$target" ] || [ -L "$target" ]; then
        backup="$(mktemp -d "${target}.backup.XXXXXX")" || return $?
        if ! mv "$target" "$backup/original"; then
            rmdir "$backup"
            return 1
        fi
        printf 'Backed up %s to %s/original\n' "$target" "$backup"
    fi

    if ! ln -s "$source_path" "$target"; then
        if [ -n "$backup" ]; then
            mv "$backup/original" "$target" || return $?
            rmdir "$backup" || return $?
        fi
        return 1
    fi
}

install_scripts() {
    if [ ! -d ~/.local/bin ]; then
        mkdir -p ~/.local/bin || return $?
    fi

    for f in ./scripts/*; do
        echo "Installing script: $f"
        link_path "$f" "$HOME/.local/bin/$(basename "$f")" || return $?
    done
}

mk_dirs() {
    if [ ! -d ~/.local/share ]; then
        mkdir -p ~/.local/share || return $?
    fi

    if [ ! -d ~/.local/share/zsh/completions ]; then
        mkdir -p ~/.local/share/zsh/completions || return $?
    fi
}

run_step "Script installation" install_scripts || exit 1
run_step "Directory setup" mk_dirs || exit 1

for f in ./install-*.sh; do
    echo "Running: $f"
    run_step "$f" "$f"
done

for d in ./config/*/; do
    name="$(basename "$d")"
    target="$HOME/.config/$name"
    pre_script="./config/pre-$name.sh"
    post_script="./config/post-$name.sh"

    echo "Processing config directory: $d"

    # Run pre-script if it exists
    if [ -f "$pre_script" ]; then
        run_step "$pre_script" bash "$pre_script" || continue
    fi

    run_step "Linking $target" link_path "$d" "$target" || continue

    # Run post-script if it exists
    if [ -f "$post_script" ]; then
        run_step "$post_script" bash "$post_script"
    fi
done

if [ "$failures" -gt 0 ]; then
    printf 'ERROR: Dotfiles setup finished with %s failed step(s)\n' "$failures" >&2
    exit 1
fi
