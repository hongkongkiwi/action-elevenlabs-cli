#!/usr/bin/env bash
# Shared utility functions for ElevenLabs CLI Action
# SECURITY MANIFEST:
#   Environment variables accessed: INPUT_API_KEY, ELEVENLABS_CLI_PATH, INPUT_VERBOSE
#   External endpoints called: via elevenlabs CLI only
#   Local files read: none
#   Local files written: none

set -euo pipefail

# Get CLI path
get_cli() {
  echo "${ELEVENLABS_CLI_PATH:-elevenlabs}"
}

# Logging with GitHub Actions annotations
log_info() {
  echo "$*"
}

log_debug() {
  if [[ "${INPUT_VERBOSE:-false}" == "true" ]]; then
    echo "[debug] $*"
  fi
}

log_warning() {
  echo "::warning::$*"
}

log_error() {
  echo "::error::$*"
}

# Set output variable
set_output() {
  local name="$1"
  local value="$2"
  echo "${name}=${value}" >> "${GITHUB_OUTPUT:-/dev/null}"
  log_debug "Set output: ${name}=${value}"
}

# Resolve voice name to voice ID
# If input is already a voice ID (starts with alphabet chars and is ~20 chars), return as-is
# Otherwise, look up voice name in available voices
resolve_voice() {
  local voice_input="$1"
  local cli
  cli=$(get_cli)
  
  # Check if already a voice ID (alphanumeric, typically 20 chars)
  if [[ "$voice_input" =~ ^[a-zA-Z0-9]{15,}$ ]]; then
    log_debug "Voice input '${voice_input}' appears to be a voice ID"
    echo "$voice_input"
    return 0
  fi
  
  log_debug "Resolving voice name: ${voice_input}"
  
  # Get voice list and find ID by name (case-insensitive)
  local voice_id
  voice_id=$("${cli}" --json voice list 2>/dev/null | \
    jq -r --arg name "${voice_input}" '.[] | select(.name | test($name; "i")) | .voice_id' | \
    head -1)
  
  if [[ -z "$voice_id" ]] || [[ "$voice_id" == "null" ]]; then
    log_warning "Voice '${voice_input}' not found, using as-is (may be a voice ID)"
    echo "$voice_input"
    return 0
  fi
  
  log_debug "Resolved voice '${voice_input}' to ID: ${voice_id}"
  echo "$voice_id"
}

# Generate default output filename based on operation
get_default_output() {
  local operation="$1"
  local format="${2:-mp3}"
  
  case "$operation" in
    tts)
      echo "output.${format%%_*}"
      ;;
    stt)
      case "$format" in
        srt) echo "transcript.srt" ;;
        vtt) echo "transcript.vtt" ;;
        json) echo "transcript.json" ;;
        *) echo "transcript.txt" ;;
      esac
      ;;
    *)
      echo "output"
      ;;
  esac
}

# Get file extension from output format
get_extension_from_format() {
  local format="$1"
  
  case "$format" in
    mp3_*) echo "mp3" ;;
    wav_*) echo "wav" ;;
    pcm_*) echo "pcm" ;;
    opus_*) echo "opus" ;;
    ulaw_*) echo "ulaw" ;;
    *) echo "${format%%_*}" ;;
  esac
}

# Retry a command with exponential backoff
retry_command() {
  local max_attempts="${1:-3}"
  local delay="${2:-5}"
  shift 2
  local cmd=("$@")
  
  local attempt=1
  while [[ $attempt -le $max_attempts ]]; do
    log_debug "Attempt ${attempt}/${max_attempts}: ${cmd[*]}"
    
    if "${cmd[@]}"; then
      return 0
    fi
    
    if [[ $attempt -lt $max_attempts ]]; then
      local wait_time=$((delay * attempt))
      log_warning "Command failed, retrying in ${wait_time}s... (attempt ${attempt}/${max_attempts})"
      sleep "$wait_time"
    fi
    
    ((attempt++))
  done
  
  log_error "Command failed after ${max_attempts} attempts: ${cmd[*]}"
  return 1
}

# Validate required input
require_input() {
  local name="$1"
  local value="$2"
  
  if [[ -z "$value" ]]; then
    log_error "Required input '${name}' is not set"
    exit 1
  fi
}

# Check if a file exists
check_file_exists() {
  local file="$1"
  
  if [[ ! -f "$file" ]]; then
    log_error "File not found: ${file}"
    exit 1
  fi
}

# Create output directory if it doesn't exist
ensure_output_dir() {
  local output_path="$1"
  local dir
  dir=$(dirname "$output_path")
  
  if [[ "$dir" != "." ]] && [[ ! -d "$dir" ]]; then
    mkdir -p "$dir"
    log_debug "Created output directory: ${dir}"
  fi
}

# Run CLI command with common options
run_cli() {
  local cli
  cli=$(get_cli)
  
  local timeout="${INPUT_TIMEOUT:-300}"
  
  # Run with timeout if available
  if command -v timeout &>/dev/null && [[ "$timeout" != "0" ]]; then
    timeout "$timeout" "${cli}" "$@"
  else
    "${cli}" "$@"
  fi
}

# Parse boolean input
parse_bool() {
  local value="$1"
  case "${value,,}" in
    true|yes|1|on) echo "true" ;;
    *) echo "false" ;;
  esac
}
