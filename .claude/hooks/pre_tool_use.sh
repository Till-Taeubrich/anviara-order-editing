#!/usr/bin/env bash
#
# Pre-tool-use hook: blocks dangerous commands before execution.
#
# Blocks:
#   1. Dangerous rm -rf commands
#   2. Direct access to .env files (use .env.sample instead)
#
# Input: JSON on stdin with { tool_name, tool_input }
# Exit 0 = allow, Exit 2 = block

set -euo pipefail

INPUT=$(cat)

TOOL_NAME=$(echo "$INPUT" | jq -r '.tool_name // empty')
TOOL_INPUT=$(echo "$INPUT" | jq -r '.tool_input // empty')

# --- Check 1: Block dangerous rm commands ---
if [ "$TOOL_NAME" = "Bash" ]; then
  COMMAND=$(echo "$TOOL_INPUT" | jq -r '.command // empty')
  COMMAND_LOWER=$(echo "$COMMAND" | tr '[:upper:]' '[:lower:]')

  # Block rm -rf / rm -fr and variations
  if echo "$COMMAND_LOWER" | grep -qE '\brm\s+.*-[a-z]*r[a-z]*f|\brm\s+.*-[a-z]*f[a-z]*r|\brm\s+--recursive\s+--force|\brm\s+--force\s+--recursive'; then
    echo "BLOCKED: Dangerous rm command detected and prevented" >&2
    exit 2
  fi
fi

# --- Check 2: Block .env file access (allow .env.sample) ---
if [ "$TOOL_NAME" = "Read" ] || [ "$TOOL_NAME" = "Edit" ] || [ "$TOOL_NAME" = "Write" ]; then
  FILE_PATH=$(echo "$TOOL_INPUT" | jq -r '.file_path // empty')
  if echo "$FILE_PATH" | grep -qE '\.env$|\.env\.' && ! echo "$FILE_PATH" | grep -qE '\.env\.sample$|\.env\.example$'; then
    echo "BLOCKED: Access to .env files containing sensitive data is prohibited. Use .env.sample instead." >&2
    exit 2
  fi
fi

if [ "$TOOL_NAME" = "Bash" ]; then
  COMMAND=$(echo "$TOOL_INPUT" | jq -r '.command // empty')
  if echo "$COMMAND" | grep -qE '(cat|less|more|head|tail|vim|nano|code|edit)\s+.*\.env\b' && ! echo "$COMMAND" | grep -qE '\.env\.sample|\.env\.example'; then
    echo "BLOCKED: Access to .env files containing sensitive data is prohibited. Use .env.sample instead." >&2
    exit 2
  fi
fi

exit 0
