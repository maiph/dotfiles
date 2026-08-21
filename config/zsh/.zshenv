# .zshenv gets sourced on all invocations of zsh
# even non-interactive ones (ie. scripts)
# Load Homebrew only if available (macOS ARM / Intel, or Linuxbrew)
for _brew in \
    /opt/homebrew/bin/brew \
    /usr/local/bin/brew \
    /home/linuxbrew/.linuxbrew/bin/brew \
    "$HOME/.linuxbrew/bin/brew"; do
    if [ -x "$_brew" ]; then
        eval "$($_brew shellenv)"
        export HOMEBREW_PREFIX="$(brew --prefix)"
        break
    fi
done
# Fall back to any brew already on PATH (e.g. user-managed install)
if [ -z "${HOMEBREW_PREFIX:-}" ] && command -v brew >/dev/null 2>&1; then
    eval "$(brew shellenv)"
    export HOMEBREW_PREFIX="$(brew --prefix)"
fi
unset _brew


export XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}" && mkdir -p "$XDG_CONFIG_HOME"
export XDG_CACHE_HOME="${XDG_CACHE_HOME:-$HOME/.cache}" && mkdir -p "$XDG_CACHE_HOME"
export XDG_DATA_HOME="${XDG_DATA_HOME:-$HOME/.local/share}" && mkdir -p "$XDG_DATA_HOME"
export XDG_STATE_HOME="${XDG_STATE_HOME:-$HOME/.local/state}" && mkdir -p "$XDG_STATE_HOME"

export COMP_DIR="${XDG_DATA_HOME}/zsh/completions"

export KUBECOLOR_OBJ_FRESH="24h"
export KUBECOLOR_CONFIG="$XDG_CONFIG_HOME/kube/color.yaml"

export LAVISH_AXI_HOST="0.0.0.0"

# export ZSH_COMPDUMP="${XDG_CACHE_HOME}/zsh/.zcompdump"

# --------------- ZSH Options ----------------
# General options
setopt AUTOCD
# History options
setopt APPEND_HISTORY
setopt SHARE_HISTORY
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_IGNORE_SPACE
# setopt HIST_SAVE_NO_DUPS # HIST_SAVE_NO_DUPS means that whatever options are set for the current session, the shell is not to save duplicated lines more than once.
# setopt HIST_FIND_NO_DUPS # HIST_FIND_NO_DUPS means that even if duplicate lines have been saved, searches backwards with editor commands don't show them more than once.
setopt HIST_NO_FUNCTIONS
setopt HIST_NO_STORE
setopt HIST_REDUCE_BLANKS

# History storage: keep it in XDG state, OUTSIDE the dotfiles git repo.
# Previously HISTFILE/HISTSIZE/SAVEHIST were never set -> zsh saved nothing
# (defaults: HISTSIZE=30, SAVEHIST=0) and the file would otherwise be
# clobbered by `git pull` / `git restore` if left under $ZDOTDIR.
export HISTFILE="${XDG_STATE_HOME}/zsh/.zsh_history"
export HISTSIZE=100000
export SAVEHIST=10000
mkdir -p "${XDG_STATE_HOME}/zsh"


export EDITOR="nvim"
# Locale: pick a locale the system actually supports (macOS ships UTF-8
# locales, but Linux only has generated ones, e.g. en_US.utf8 or C.utf8).
_set_locale() {
    for loc in "en_US.UTF-8" "en_US.utf8" "C.UTF-8" "C.utf8"; do
        if locale -a 2>/dev/null | grep -qi "^${loc}$"; then
            export LANG="$loc"; return 0
        fi
    done
    # fall back to any UTF-8 locale still present
    if loc=$(locale -a 2>/dev/null | grep -i 'utf' | head -n1); then
        [ -n "$loc" ] && export LANG="$loc"; return 0
    fi
    return 1
}
if [ -z "$LANG" ] || ! locale -a 2>/dev/null | grep -qi "^${LANG}$"; then
    _set_locale
fi
unset -f _set_locale
# sdkman_auto_complete="false"
export ZSH_DISABLE_COMPFIX="true"

# SDKMAN (only when installed via Homebrew)
if [ -n "${HOMEBREW_PREFIX:-}" ] && [ -d "${HOMEBREW_PREFIX}/opt/sdkman-cli/libexec" ]; then
    export SDKMAN_DIR="${HOMEBREW_PREFIX}/opt/sdkman-cli/libexec"
fi
if [ -n "${SDKMAN_DIR:-}" ] && [ -s "${SDKMAN_DIR}/bin/sdkman-init.sh" ]; then
    sdkman_auto_complete=false
    source "${SDKMAN_DIR}/bin/sdkman-init.sh"
fi
