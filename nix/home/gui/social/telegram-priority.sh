#!/usr/bin/env bash
declare -A clients=() owners=() node_binary=() active=() paused=()
was_telegram=0

pause_players() {
  local player status track
  while IFS= read -r player; do
    [[ -z "$player" ]] && continue
    case "${player,,}" in
      (*telegram*|*ayugram*|plasma-browser-integration) continue ;;
    esac
    status=$(playerctl --player="$player" status 2>/dev/null) || continue
    [[ "$status" == "Playing" ]] || continue
    track=$(playerctl --player="$player" metadata mpris:trackid 2>/dev/null) || track=
    paused["$player"]="$track"
    playerctl --player="$player" pause 2>/dev/null || true
  done < <(playerctl --list-all 2>/dev/null)
}

resume_players() {
  local player status track
  for player in "${!paused[@]}"; do
    status=$(playerctl --player="$player" status 2>/dev/null) || continue
    track=$(playerctl --player="$player" metadata mpris:trackid 2>/dev/null) || track=
    if [[ "$status" == "Paused" ]]; then
      if [[ -z "${paused[$player]}" || -z "$track" || "$track" == "${paused[$player]}" ]]; then
        playerctl --player="$player" play 2>/dev/null || true
      fi
    fi
    unset 'paused[$player]'
  done
}

is_telegram_active() {
  local id source
  for id in "${!active[@]}"; do
    source="${node_binary[$id]} ${clients[${owners[$id]}]-}"
    case "${source,,}" in
      (*ayugram*|*telegram*) return 0 ;;
    esac
  done
  return 1
}

trap resume_players EXIT
trap 'exit 0' TERM INT

while IFS=$'\t' read -r id kind owner binary state corked; do
  case "$kind" in
    (client)
      clients["$id"]="$binary"
      ;;
    (node)
      owners["$id"]="$owner"
      node_binary["$id"]="$binary"
      if [[ "$state" == "running" && "$corked" != "true" ]]; then
        active["$id"]=1
      else
        unset 'active[$id]'
      fi
      ;;
    (removed)
      unset 'clients[$id]' 'owners[$id]' 'node_binary[$id]' 'active[$id]'
      ;;
  esac

  if is_telegram_active; then
    if (( !was_telegram )); then
      was_telegram=1
      pause_players
    fi
  else
    if (( was_telegram )); then
      was_telegram=0
      resume_players
    fi
  fi
done < <(
  pw-dump -m -N | jq --unbuffered -r '
    .[] |
    if .info == null then [.id, "removed", "-", "-", "-", "-"] | @tsv
    elif .type == "PipeWire:Interface:Client" then
      [.id, "client", "-", (.info.props."application.process.binary" // .info.props."application.name" // "-"), "-", "-"] | @tsv
    elif .type == "PipeWire:Interface:Node" and (.info.props."media.class" == "Stream/Output/Audio" or .info.props."media.class" == "Stream/Input/Audio") then
      [.id, "node", (.info.props."client.id" // "-"), (.info.props."application.process.binary" // .info.props."application.name" // "-"), (.info.state // "-"), (.info.props."pulse.corked" // false | tostring)] | @tsv
    else empty end
  '
)
