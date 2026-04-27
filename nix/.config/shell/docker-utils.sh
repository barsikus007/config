#!/bin/bash

# TODO: fzf selection: https://www.reddit.com/r/docker/comments/vovo2b/dockerfzf_exec_bash_if_found_otherwise_sh/
dcsh() { docker compose exec -it "$1" sh -c 'bash || sh'; }

dcsha() {
  #? dcsh with aliases
  local container=$1
  if [[ -z "$container" ]]; then
    echo "Usage: dcsha <container_name>"
    return 1
  fi

  # 1. Pipe host aliases and standard .bashrc sourcing directly into the container
  # Sourcing ~/.bashrc ensures you don't lose the container's default paths and prompt.
  {
    echo '[[ -f ~/.bashrc ]] && source ~/.bashrc'
    if [[ -n "$ZSH_VERSION" ]]; then
      alias -L
    else
      alias
    fi
  } | docker exec -i "$container" bash -c 'cat > /tmp/.custom_rc'

  # 2. Execute interactive bash using the injected rcfile
  docker exec -it "$container" bash --rcfile /tmp/.custom_rc
}

dclf() {
  while true; do
    docker compose logs --tail 1000 -f "$@"
    echo 'Container stopped, restarting...'
    sleep 1
  done
}

alias docker-clear-logs='sudo sh -c "truncate -s 0 /var/lib/docker/containers/*/*-json.log"'
