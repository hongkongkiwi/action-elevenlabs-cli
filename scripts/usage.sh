#!/usr/bin/env bash
# Usage monitoring operation handler
# SECURITY MANIFEST:
#   Environment variables accessed: INPUT_* variables
#   External endpoints called: api.elevenlabs.io (via CLI)
#   Local files read: None
#   Local files written: None

handle_usage() {
  local cli
  cli=$(get_cli)
  
  log_info "Fetching usage statistics..."
  
  # Get usage stats
  local args=()
  args+=("--json" "usage" "stats")
  
  local result
  result=$(run_cli "${args[@]}" 2>&1)
  
  echo "$result"
  
  # Parse usage information
  local threshold="${INPUT_USAGE_THRESHOLD:-80}"
  
  # Extract usage percentage (this depends on the CLI output format)
  # The CLI returns JSON with usage data
  local character_count character_limit percentage
  
  character_count=$(echo "$result" | jq -r '.character_count // .used_characters // 0' 2>/dev/null || echo "0")
  character_limit=$(echo "$result" | jq -r '.character_limit // .limit // 1' 2>/dev/null || echo "1")
  
  if [[ "$character_limit" != "0" ]] && [[ "$character_limit" != "null" ]] && [[ -n "$character_limit" ]]; then
    percentage=$(( (character_count * 100) / character_limit ))
  else
    percentage=0
  fi
  
  log_info "Usage: ${character_count} / ${character_limit} characters (${percentage}%)"
  
  # Set output
  set_output "usage-info" "$result"
  
  # Check threshold
  if [[ "$percentage" -ge "$threshold" ]]; then
    log_warning "Usage (${percentage}%) exceeds threshold (${threshold}%)"
  fi
  
  # Also show user info
  log_info "Fetching user info..."
  run_cli "user" "info" 2>&1 || true
}
