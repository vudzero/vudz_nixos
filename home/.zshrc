# Vanilla zsh configuration

# Add zsh-completions to fpath
fpath+=(/run/current-system/sw/share/zsh-completions)

# Enable completion system
autoload -Uz compinit
compinit

# History settings
HISTFILE=~/.config/zsh_history
HISTSIZE=10000
SAVEHIST=10000
setopt SHARE_HISTORY           # Share history between sessions
setopt HIST_IGNORE_DUPS        # Don't record duplicate entries
setopt HIST_IGNORE_ALL_DUPS    # Remove older duplicates
setopt HIST_FIND_NO_DUPS       # Don't display duplicates when searching
setopt HIST_SAVE_NO_DUPS       # Don't save duplicates

# Directory navigation
setopt AUTO_CD                 # Just type directory name to cd
setopt AUTO_PUSHD              # Push old directory onto stack
setopt PUSHD_IGNORE_DUPS       # Don't push duplicates
setopt PUSHD_SILENT            # Don't print directory stack

# Git integration for prompt
autoload -Uz vcs_info
precmd() { vcs_info }
zstyle ':vcs_info:git:*' formats '%F{yellow}(%b)%f '
setopt PROMPT_SUBST

# Prompt with git branch
PROMPT='%F{cyan}%~%f ${vcs_info_msg_0_}%# '

# Aliases
alias ls='ls -l --color=auto'
alias ll='ls -lah'
alias la='ls -A'
alias grep='grep --color=auto'

# Case-insensitive completion
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'

# Menu-style completion
zstyle ':completion:*' menu select

# Autosuggestions keybindings
bindkey '^I' autosuggest-accept  # TAB accepts autosuggestion
bindkey '^[[Z' expand-or-complete  # SHIFT+TAB for menu completion
