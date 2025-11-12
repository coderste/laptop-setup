# ================================
# Environment Variables
# ================================

# Oh My Zsh configuration
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="apple"
DEFAULT_USER="$USER"

# Disable auto-title for better terminal control
DISABLE_AUTO_TITLE="true"

# History settings
HIST_STAMPS="yyyy-mm-dd"
HISTSIZE=10000
SAVEHIST=10000

# ================================
# PATH Configuration
# ================================

# Reset to system defaults for consistency
export PATH="/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin"

# Homebrew (handles both Intel and Apple Silicon)
if [[ -d "/opt/homebrew" ]]; then
    export PATH="/opt/homebrew/bin:/opt/homebrew/sbin:$PATH"
elif [[ -d "/usr/local/Homebrew" ]]; then
    export PATH="/usr/local/bin:$PATH"
fi

# User-specific paths
export PATH="$HOME/.local/bin:$PATH"

# Development tools
export PATH="$HOME/.composer/vendor/bin:$PATH"

# Golang configuration
if command -v brew >/dev/null 2>&1 && brew list golang >/dev/null 2>&1; then
    export GOROOT="$(brew --prefix golang)/libexec"
    export GOPATH="$HOME/go"
    export PATH="$PATH:$GOROOT/bin:$GOPATH/bin"
fi

# Perl (if installed via Homebrew)
if [[ -d "/opt/homebrew/opt/perl/bin" ]]; then
    export PATH="/opt/homebrew/opt/perl/bin:$PATH"
fi

# PNPM (if using specific version)

# ================================
# Oh My Zsh Plugins
# ================================

plugins=(
    git
    zsh-autosuggestions
    zsh-syntax-highlighting
)

# ================================
# Terminal Configuration
# ================================

# Dynamic terminal title based on current directory
case $TERM in
    xterm*|screen*|tmux*)
        precmd() { print -Pn "\e]0;%~\a" }
        ;;
esac

# ================================
# Load Oh My Zsh
# ================================

source $ZSH/oh-my-zsh.sh

# ================================
# Node Version Manager (NVM)
# ================================

# ================================
# Custom Aliases and Functions
# ================================

# Source custom aliases if file exists
if [[ -f "$HOME/.aliases" ]]; then
    source "$HOME/.aliases"
fi

# Vim/Neovim aliases
alias vim='nvim'
alias vi='nvim'

# VSCode
alias vs="code ."

# ================================
# Development Environment Setup
# ================================

eval "$(fnm env --use-on-cd)"

# Homebrew environment (if not already set)
if [[ -f "/opt/homebrew/bin/brew" ]]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
elif [[ -f "/usr/local/bin/brew" ]]; then
    eval "$(/usr/local/bin/brew shellenv)"
fi

# ================================
# Performance Optimizations
# ================================
autoload -Uz compinit
if [[ -n ${HOME}/.zcompdump(#qN.mh+24) ]]; then
    compinit
else
    compinit -C
fi

export SSH_AUTH_SOCK=~/Library/Group\ Containers/2BUA8C4S2C.com.1password/t/agent.sock
