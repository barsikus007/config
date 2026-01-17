#!/bin/bash

dclf() {
  while true; do
    docker compose logs --tail 1000 -f "$@"
    echo 'Container stopped, restarting...'
    sleep 1
  done
}
