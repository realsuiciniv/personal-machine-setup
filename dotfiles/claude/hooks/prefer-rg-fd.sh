#!/bin/bash
# Hook: prefer-rg-fd
# Intercepts Bash tool calls that use grep or find and redirects Claude to use
# ripgrep (rg) and fd instead, which are faster and respect .gitignore by default.

INPUT=$(cat)
COMMAND=$(echo "$INPUT" | jq -r '.tool_input.command // empty')

uses_grep=false
uses_find=false

# Match grep/find at the start of a command or after shell operators (;, &&, ||, |, newline)
if echo "$COMMAND" | grep -qE '(^|[;&|]\s*|\n\s*)grep(\s|$)'; then
  uses_grep=true
fi

if echo "$COMMAND" | grep -qE '(^|[;&|]\s*|\n\s*)find(\s|$)'; then
  uses_find=true
fi

if $uses_grep || $uses_find; then
  message=""

  if $uses_grep && $uses_find; then
    message="Use rg (ripgrep) instead of grep, and fd instead of find. Both are available and faster — they respect .gitignore by default. Examples: rg \"pattern\" src/ | fd \"filename\" src/"
  elif $uses_grep; then
    message="Use rg (ripgrep) instead of grep. It is available, faster, and respects .gitignore by default. Example: rg \"pattern\" src/"
  else
    message="Use fd instead of find. It is available, faster, and respects .gitignore by default. Example: fd \"filename\" src/"
  fi

  jq -n --arg msg "$message" '{
    hookSpecificOutput: {
      hookEventName: "PreToolUse",
      permissionDecision: "deny",
      permissionDecisionReason: $msg
    }
  }'
  exit 0
fi

exit 0
