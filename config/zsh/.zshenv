# .zshenv gets sourced on all invocations of zsh
# even non-interactive ones (ie. scripts)
# Load Homebrew only if available (macOS / linuxbrew)
if [ -x /opt/homebrew/bin/brew ]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
    export HOMEBREW_PREFIX="$(brew --prefix)"
elif command -v brew >/dev/null 2>&1; then
    eval "$(brew shellenv)"
    export HOMEBREW_PREFIX="$(brew --prefix)"
fi


export XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}" && mkdir -p "$XDG_CONFIG_HOME"
export XDG_CACHE_HOME="${XDG_CACHE_HOME:-$HOME/.cache}" && mkdir -p "$XDG_CACHE_HOME"
export XDG_DATA_HOME="${XDG_DATA_HOME:-$HOME/.local/share}" && mkdir -p "$XDG_DATA_HOME"
export XDG_STATE_HOME="${XDG_STATE_HOME:-$HOME/.local/state}" && mkdir -p "$XDG_STATE_HOME"

export COMP_DIR="${XDG_DATA_HOME}/zsh/completions"

export KUBECOLOR_OBJ_FRESH="24h"
export KUBECOLOR_CONFIG="$XDG_CONFIG_HOME/kube/color.yaml"

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


export LANG="en_US.UTF-8"
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
