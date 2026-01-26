# Path to oh-my-zsh installation (managed by NixOS)
# Try system path first, fall back to nix store if needed
if [ -f "/run/current-system/sw/share/oh-my-zsh/oh-my-zsh.sh" ]; then
  export ZSH="/run/current-system/sw/share/oh-my-zsh"
elif [ -d "$HOME/.oh-my-zsh" ]; then
  export ZSH="$HOME/.oh-my-zsh"
else
  # Find oh-my-zsh in nix store
  ZSH_NIX_PATH=$(ls -d /nix/store/*oh-my-zsh-*/share/oh-my-zsh 2>/dev/null | head -1)
  if [ -n "$ZSH_NIX_PATH" ]; then
    export ZSH="$ZSH_NIX_PATH"
  fi
fi

# Set theme (use robbyrussell for now, catppuccin requires manual installation)
ZSH_THEME="robbyrussell"

# Plugins
plugins=(git docker)

# Load oh-my-zsh if found
if [ -f "$ZSH/oh-my-zsh.sh" ]; then
  source $ZSH/oh-my-zsh.sh
else
  echo "Warning: oh-my-zsh not found. Run ./deploy-nixos.sh to install."
fi

# Load zsh-autosuggestions (fish-like autosuggestions from history)
if [ -f /run/current-system/sw/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh ]; then
  source /run/current-system/sw/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
fi

# Load zsh-syntax-highlighting (must be loaded after all other plugins)
ZSH_SYNTAX_HIGHLIGHTING=$(find /nix/store -name "zsh-syntax-highlighting.zsh" -path "*/share/zsh-syntax-highlighting/*" 2>/dev/null | head -1)
if [ -n "$ZSH_SYNTAX_HIGHLIGHTING" ]; then
  source "$ZSH_SYNTAX_HIGHLIGHTING"
fi

# Completion settings (ensure they're enabled after oh-my-zsh loads)
autoload -Uz compinit
compinit

# Case-insensitive completion
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}' 'r:|[._-]=* r:|=*' 'l:|=* r:|=*'

# Menu-style completion with colors
zstyle ':completion:*' menu select
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"

# Completion caching
zstyle ':completion:*' use-cache on
zstyle ':completion:*' cache-path ~/.cache/zsh

# Better completion for kill command
zstyle ':completion:*:*:kill:*:processes' list-colors '=(#b) #([0-9]#)*=0=01;31'
zstyle ':completion:*:kill:*' command 'ps -u $USER -o pid,%cpu,tty,cputime,cmd'

# History settings
HISTFILE=~/.config/zsh_history
HISTSIZE=10000
SAVEHIST=10000
setopt SHARE_HISTORY
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_FIND_NO_DUPS
setopt HIST_SAVE_NO_DUPS

# Directory navigation
setopt AUTO_CD              # Just type directory name to cd
setopt AUTO_PUSHD           # Push old directory onto stack
setopt PUSHD_IGNORE_DUPS    # Don't push duplicates
setopt PUSHD_SILENT         # Don't print directory stack

# Aliases
alias ls='ls --color=auto'
alias ll='ls -lah'
alias la='ls -A'
alias grep='grep --color=auto'
