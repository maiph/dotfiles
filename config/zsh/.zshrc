typeset -U path fpath cdpath
# Google Cloud SDK bin (only when Homebrew+gcloud is present)
gcloud_bin=""
if [ -n "${HOMEBREW_PREFIX:-}" ] && [ -d "${HOMEBREW_PREFIX}/share/google-cloud-sdk/bin" ]; then
    gcloud_bin="${HOMEBREW_PREFIX}/share/google-cloud-sdk/bin"
fi
path=(~/bin ~/.local/bin ~/go/bin $gcloud_bin $path)
unset gcloud_bin
fpath=($XDG_DATA_HOME/zsh/completions $fpath)
cdpath=(~ ~/dev $cdpath)
export CDPATH

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

export FZF_DEFAULT_OPTS="--height 30% --layout reverse --border bottom \
    --color=bg+:#313244,bg:#1E1E2E,spinner:#F5E0DC,hl:#F38BA8 \
    --color=fg:#CDD6F4,header:#F38BA8,info:#CBA6F7,pointer:#F5E0DC \
    --color=marker:#B4BEFE,fg+:#CDD6F4,prompt:#CBA6F7,hl+:#F38BA8 \
    --color=selected-bg:#45475A \
    --color=border:#6C7086,label:#CDD6F4"


PROMPT_DIR_PREFIXES=("~/dev")

precmd() {
    local dir=${(%):-%~}
    for prefix in $PROMPT_DIR_PREFIXES; do
        if [[ $dir == $prefix/* ]]; then
            dir="${dir#$prefix/}"; break
        fi
    done
    psvar[1]=$dir

    local branch
    branch=$(git branch --show-current 2>/dev/null)
    psvar[2]=${branch:+($branch) }
}

PS1="%F{blue}%1v %F{#f38ba8}%2v%f%(?.%F{green}.%F{red})\$%f "
PS4="$ "

# Load aliases
if [[ -r ${ZDOTDIR:-$HOME}/.aliasrc ]]; then
    . ${ZDOTDIR:-$HOME}/.aliasrc
fi

# export ZSH_COMPDUMP="${XDG_CACHE_HOME}/zsh/.zcompdump"
autoload -Uz compinit
compinit -d $XDG_CACHE_HOME/zsh/.zcompdump

# Google Cloud SDK completions (only when Homebrew + gcloud is present)
if [ -n "${HOMEBREW_PREFIX:-}" ] && [ -f "${HOMEBREW_PREFIX}/share/google-cloud-sdk/completion.zsh.inc" ]; then
    . "${HOMEBREW_PREFIX}/share/google-cloud-sdk/completion.zsh.inc"
fi

compdef kubecolor=kubectl

# fzf configuration
FZF_CTRL_T_COMMAND= FZF_ALT_C_COMMAND= source <(fzf --zsh)

# Theme
. $XDG_CONFIG_HOME/zsh/catppuccin-mocha.zsh
