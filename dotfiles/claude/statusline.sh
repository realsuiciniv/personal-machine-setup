#!/usr/bin/env bash

# ANSI color codes
GREEN='\033[0;32m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
WHITE='\033[0;37m'
YELLOW='\033[0;33m'
AMBER='\033[0;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
BOLD='\033[1m'
RESET='\033[0m'

SEP=" || "

input=$(cat)

# --- 0. Project folder name (always main worktree root, not worktree dir) ---
cwd_raw=$(echo "$input" | jq -r '.workspace.current_dir // empty')
if [ -n "$cwd_raw" ] && git -C "$cwd_raw" --no-optional-locks rev-parse --git-dir > /dev/null 2>&1; then
    main_worktree=$(git -C "$cwd_raw" --no-optional-locks worktree list --porcelain 2>/dev/null | awk 'NR==1{print $2}')
    if [ -n "$main_worktree" ]; then
        project_name=$(basename "$main_worktree")
    else
        project_name=$(basename "$cwd_raw")
    fi
elif [ -n "$cwd_raw" ]; then
    project_name=$(basename "$cwd_raw")
else
    project_name=$(basename "$PWD")
fi
seg0=$(printf "${BOLD}${YELLOW}%s${RESET}" "$project_name")

# --- 1. Model name + context window ---
model=$(echo "$input" | jq -r '.model.display_name // "unknown"')
ctx_size=$(echo "$input" | jq -r '.context_window.context_window_size // 0')
if [ "$ctx_size" -ge 1000000 ] 2>/dev/null; then
    ctx_label="$(echo "$ctx_size" | awk '{printf "%dM", $1/1000000}') context"
elif [ "$ctx_size" -ge 1000 ] 2>/dev/null; then
    ctx_label="$(echo "$ctx_size" | awk '{printf "%dk", $1/1000}') context"
else
    ctx_label="${ctx_size} context"
fi
seg1=$(printf "${CYAN}%s${RESET} ${WHITE}(%s)${RESET}" "$model" "$ctx_label")

# --- 2. Git branch: "work -> main" ---
cwd="$cwd_raw"
seg2=""
if [ -n "$cwd" ] && git -C "$cwd" --no-optional-locks rev-parse --git-dir > /dev/null 2>&1; then
    current_branch=$(git -C "$cwd" --no-optional-locks symbolic-ref --short HEAD 2>/dev/null \
                     || git -C "$cwd" --no-optional-locks rev-parse --short HEAD 2>/dev/null)
    # Detect default/main branch
    default_branch=$(git -C "$cwd" --no-optional-locks symbolic-ref refs/remotes/origin/HEAD 2>/dev/null \
                     | sed 's|refs/remotes/origin/||')
    [ -z "$default_branch" ] && default_branch="main"
    dirty=""
    if ! git -C "$cwd" --no-optional-locks diff --quiet 2>/dev/null || \
       ! git -C "$cwd" --no-optional-locks diff --cached --quiet 2>/dev/null; then
        dirty="${YELLOW}*${RESET}"
    fi
    if [ -n "$current_branch" ] && [ "$current_branch" != "$default_branch" ]; then
        seg2=$(printf "${MAGENTA}%s${RESET}${dirty} ${BLUE}-> %s${RESET}" "$current_branch" "$default_branch")
    elif [ -n "$current_branch" ]; then
        seg2=$(printf "${WHITE}%s${RESET}${dirty}" "$current_branch")
    fi
fi

# --- 3+4. Context usage: percentage + token count ---
total_input=$(echo "$input" | jq -r '.context_window.total_input_tokens // 0')
total_output=$(echo "$input" | jq -r '.context_window.total_output_tokens // 0')
total_tokens=$((total_input + total_output))
tokens_k=$(awk "BEGIN {printf \"%.1fk\", $total_tokens/1000}")

ctx_used_pct=$(echo "$input" | jq -r '.context_window.used_percentage // 0')
if [ "$ctx_used_pct" -le 30 ] 2>/dev/null; then
    ctx_color="$GREEN"
elif [ "$ctx_used_pct" -le 60 ] 2>/dev/null; then
    ctx_color="$AMBER"
else
    ctx_color="$RED"
fi
seg4=$(printf "${ctx_color}%s%% (%s tokens)${RESET}" "$ctx_used_pct" "$tokens_k")

# --- 5. Session cost ---
total_cost=$(echo "$input" | jq -r '.cost.total_cost_usd // 0')
cost_fmt=$(printf "%.2f" "$total_cost" 2>/dev/null || echo "0.00")
seg5=$(printf "${WHITE}\$%s${RESET}" "$cost_fmt")

# --- 6. Cache hit ratio ---
cache_read=$(echo "$input" | jq -r '.context_window.current_usage.cache_read_input_tokens // 0')
cache_create=$(echo "$input" | jq -r '.context_window.current_usage.cache_creation_input_tokens // 0')
input_tokens=$(echo "$input" | jq -r '.context_window.current_usage.input_tokens // 0')
total_call=$((cache_read + cache_create + input_tokens))
if [ "$total_call" -gt 0 ] 2>/dev/null; then
    cache_pct=$(awk "BEGIN {printf \"%.0f\", ($cache_read / $total_call) * 100}" 2>/dev/null || echo "0")
else
    cache_pct=0
fi
seg6=$(printf "${CYAN}%s%% cached${RESET}" "$cache_pct")

# --- Assemble ---
line="$seg0${SEP}${seg1}"
[ -n "$seg2" ] && line="${line}${SEP}${seg2}"
line="${line}${SEP}${seg4}${SEP}${seg5}${SEP}${seg6}"

printf "%b\n" "$line"
