# Nushell Environment Config File

# Directories to search for scripts when calling source or use
$env.NU_LIB_DIRS = [
    ($nu.default-config-dir | path join 'scripts')
]

# Directories to search for plugin binaries when calling register
$env.NU_PLUGIN_DIRS = [
    ($nu.default-config-dir | path join 'plugins')
]

# Set PATH
$env.PATH = ($env.PATH | split row (char esep))

# Generate carapace completions if not exists
let carapace_cache = ($nu.home-path | path join ".cache/carapace")
let carapace_init = ($carapace_cache | path join "init.nu")
if not ($carapace_init | path exists) {
  mkdir $carapace_cache
  carapace _carapace nushell | save --force $carapace_init
}

# SSH Agent Configuration
let ssh_env_file = ($nu.home-path | path join ".ssh/agent-environment")

# Function to start SSH agent
def start_ssh_agent [] {
  print "Initializing new SSH agent..."
  let agent_output = (ssh-agent -c | lines | where {|line| $line =~ "setenv"} | str replace "setenv " "" | str replace ";" "")

  let ssh_auth_sock = ($agent_output | where {|line| $line =~ "SSH_AUTH_SOCK"} | first | split row " " | last)
  let ssh_agent_pid = ($agent_output | where {|line| $line =~ "SSH_AGENT_PID"} | first | split row " " | last)

  $"SSH_AUTH_SOCK=($ssh_auth_sock); export SSH_AUTH_SOCK;\nSSH_AGENT_PID=($ssh_agent_pid); export SSH_AGENT_PID;" | save --force $ssh_env_file

  $env.SSH_AUTH_SOCK = $ssh_auth_sock
  $env.SSH_AGENT_PID = $ssh_agent_pid

  ssh-add ~/.ssh/id_rsa
  print "SSH agent started"
}

# Check if agent environment file exists and load it
if ($ssh_env_file | path exists) {
  let env_content = (open $ssh_env_file | lines | where {|line| $line =~ "SSH_"})

  try {
    let auth_sock = ($env_content | where {|line| $line =~ "SSH_AUTH_SOCK"} | first | parse "SSH_AUTH_SOCK={sock}" | get sock | first)
    let agent_pid = ($env_content | where {|line| $line =~ "SSH_AGENT_PID"} | first | parse "SSH_AGENT_PID={pid}" | get pid | first)

    # Check if agent is still running
    let is_running = (ps | where pid == ($agent_pid | into int) | length) > 0

    if $is_running {
      $env.SSH_AUTH_SOCK = $auth_sock
      $env.SSH_AGENT_PID = $agent_pid
    } else {
      start_ssh_agent
    }
  } catch {
    start_ssh_agent
  }
} else {
  start_ssh_agent
}
