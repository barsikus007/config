#!/usr/bin/env bash

CLAUDE_CONFIG_FILE="${CLAUDE_CONFIG_DIR:-$HOME/.claude}/settings.json"

claude_reset() {
  jq --indent 2 '.env |= del(
    .ANTHROPIC_MODEL,
    .ANTHROPIC_DEFAULT_OPUS_MODEL,
    .ANTHROPIC_DEFAULT_SONNET_MODEL,
    .ANTHROPIC_DEFAULT_HAIKU_MODEL,
    .ANTHROPIC_DEFAULT_FABLE_MODEL,
    .ANTHROPIC_SMALL_FAST_MODEL,
    .CLAUDE_CODE_SUBAGENT_MODEL,
    .CLAUDE_CODE_AUTO_COMPACT_WINDOW,
    .CLAUDE_CODE_EFFORT_LEVEL
  )' "$CLAUDE_CONFIG_FILE" > "$CLAUDE_CONFIG_FILE.tmp" && mv --force "$CLAUDE_CONFIG_FILE.tmp" "$CLAUDE_CONFIG_FILE"
}

claude_grok() {
  claude_reset
  jq --indent 2 '.env += (
    [
      "ANTHROPIC_MODEL",
      "ANTHROPIC_DEFAULT_OPUS_MODEL",
      "ANTHROPIC_DEFAULT_SONNET_MODEL",
      "ANTHROPIC_DEFAULT_HAIKU_MODEL",
      "ANTHROPIC_DEFAULT_FABLE_MODEL",
      "CLAUDE_CODE_SUBAGENT_MODEL"
    ]
    | map({(.): "grok-4.6"})
    | add
    | . + {
      CLAUDE_CODE_AUTO_COMPACT_WINDOW: "500000"
    }
  )' "$CLAUDE_CONFIG_FILE" > "$CLAUDE_CONFIG_FILE.tmp" && mv --force "$CLAUDE_CONFIG_FILE.tmp" "$CLAUDE_CONFIG_FILE"
}

claude_kimi() {
  claude_reset
  jq --indent 2 '.env += (
    [
      "ANTHROPIC_MODEL",
      "ANTHROPIC_DEFAULT_OPUS_MODEL",
      "ANTHROPIC_DEFAULT_SONNET_MODEL",
      "ANTHROPIC_DEFAULT_HAIKU_MODEL",
      "ANTHROPIC_DEFAULT_FABLE_MODEL",
      "CLAUDE_CODE_SUBAGENT_MODEL"
    ]
    | map({(.): "kimi-k3[1m]"})
    | add
    | . + {
      CLAUDE_CODE_AUTO_COMPACT_WINDOW: "1048576",
      CLAUDE_CODE_EFFORT_LEVEL: "max"
    }
  )' "$CLAUDE_CONFIG_FILE" > "$CLAUDE_CONFIG_FILE.tmp" && mv --force "$CLAUDE_CONFIG_FILE.tmp" "$CLAUDE_CONFIG_FILE"
}

claude_gpt() {
  claude_reset
  jq --indent 2 '.env += (
    ([
      "ANTHROPIC_MODEL",
      "ANTHROPIC_DEFAULT_OPUS_MODEL",
      "ANTHROPIC_DEFAULT_FABLE_MODEL"
    ]
    | map({(.): "gpt-5.6-sol[1m]"}) | add) +
    ([
      "ANTHROPIC_DEFAULT_SONNET_MODEL",
      "CLAUDE_CODE_SUBAGENT_MODEL"
    ]
    | map({(.): "gpt-5.6-terra[1m]"}) | add) +
    ([
      "ANTHROPIC_DEFAULT_HAIKU_MODEL",
      "ANTHROPIC_SMALL_FAST_MODEL"
    ]
    | map({(.): "gpt-5.6-luna[1m]"}) | add) +
    {
      CLAUDE_CODE_AUTO_COMPACT_WINDOW: "372000",
      CLAUDE_CODE_EFFORT_LEVEL: "max"
    }
  )' "$CLAUDE_CONFIG_FILE" > "$CLAUDE_CONFIG_FILE.tmp" && mv --force "$CLAUDE_CONFIG_FILE.tmp" "$CLAUDE_CONFIG_FILE"
}

claude_gemini() {
  claude_reset
  jq --indent 2 '.env += (
    ([
      "ANTHROPIC_MODEL",
      "ANTHROPIC_DEFAULT_OPUS_MODEL",
      "ANTHROPIC_DEFAULT_FABLE_MODEL",
      "ANTHROPIC_DEFAULT_SONNET_MODEL",
      "CLAUDE_CODE_SUBAGENT_MODEL"
    ]
    | map({(.): "gemini-3.8-flash"}) | add) +
    ([
      "ANTHROPIC_DEFAULT_HAIKU_MODEL",
      "ANTHROPIC_SMALL_FAST_MODEL"
    ]
    | map({(.): "gemini-3.5-flash-lite"}) | add) +
    {
      CLAUDE_CODE_AUTO_COMPACT_WINDOW: "1048576",
      CLAUDE_CODE_EFFORT_LEVEL: "high"
    }
  )' "$CLAUDE_CONFIG_FILE" > "$CLAUDE_CONFIG_FILE.tmp" && mv --force "$CLAUDE_CONFIG_FILE.tmp" "$CLAUDE_CONFIG_FILE"
}
