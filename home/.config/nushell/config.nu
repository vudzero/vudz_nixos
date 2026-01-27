# Nushell Config File

# The default config record. This is where much of your global configuration is setup.
$env.config = {
  show_banner: false

  edit_mode: emacs

  completions: {
    algorithm: "fuzzy"  # or "prefix"
    quick: true
    partial: true
    case_sensitive: false
  }

  shell_integration: {
    osc2: true
    osc7: true
    osc8: true
    osc9_9: false
    osc133: true
    osc633: true
    reset_application_mode: true
  }
}

# Custom alias to run claude in zsh
alias claude = with-env { SHELL: "/bin/zsh" } { claude }

# Enable carapace completions
$env.CARAPACE_BRIDGES = 'zsh,fish,bash,inshellisense'
source ~/.cache/carapace/init.nu
