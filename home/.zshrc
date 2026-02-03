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
bindkey '^I' expand-or-complete  # TAB for menu completion
bindkey '^[[Z' autosuggest-accept  # SHIFT+TAB accepts autosuggestion

# Key bindings for word and line navigation
bindkey '\e[1;3D' backward-word      # Alt+Left - move backward one word
bindkey '\e[1;3C' forward-word       # Alt+Right - move forward one word
bindkey '\e[1;5D' beginning-of-line  # Ctrl+Left - move to beginning of line
bindkey '\e[1;5C' end-of-line        # Ctrl+Right - move to end of line

# Key bindings for deletion
bindkey '\e[3;3~' kill-word           # Alt+Delete - delete word forward
bindkey '^H' backward-kill-line       # Ctrl+Delete - delete from cursor to beginning of line
