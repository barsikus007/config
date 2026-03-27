#!/bin/bash

dcsh() { docker compose exec -it "$1" sh -c 'bash || sh'; }

dclf() {
  while true; do
    docker compose logs --tail 1000 -f "$@"
    echo 'Container stopped, restarting...'
    sleep 1
  done
}

alias docker-clear-logs='sudo sh -c "truncate -s 0 /var/lib/docker/containers/*/*-json.log"'
