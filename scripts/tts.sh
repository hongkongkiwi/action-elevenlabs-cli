#!/usr/bin/env bash
# TTS (Text-to-Speech) operation handler
# SECURITY MANIFEST:
#   Environment variables accessed: INPUT_* variables
#   External endpoints called: api.elevenlabs.io (via CLI)
#   Local files read: INPUT_TEXT_FILE if specified
#   Local files written: Output audio file

handle_tts() {
  local cli
  cli=$(get_cli)
  
  # Get text input
  local text="${INPUT_TEXT:-}"
  local text_file="${INPUT_TEXT_FILE:-}"
  
  if [[ -z "$text" ]] && [[ -z "$text_file" ]]; then
    log_error "Either 'text' or 'text-file' input is required for TTS"
    exit 1
  fi
  
  if [[ -n "$text_file" ]]; then
    check_file_exists "$text_file"
    log_debug "Reading text from file: ${text_file}"
  fi
  
  # Resolve voice name to ID
  local voice_input="${INPUT_VOICE:-Brian}"
  local voice_id
  voice_id=$(resolve_voice "$voice_input")
  
  set_output "voice-id" "$voice_id"
  
  # Build command arguments
  local args=()
  args+=("tts")
  
  # Add text or file
  if [[ -n "$text_file" ]]; then
    args+=("--file" "$text_file")
  else
    args+=("$text")
  fi
  
  # Add voice
  args+=("--voice" "$voice_id")
  
  # Add model
  args+=("--model" "${INPUT_MODEL:-eleven_multilingual_v2}")
  
  # Determine output file
  local output="${INPUT_OUTPUT:-}"
  local format="${INPUT_OUTPUT_FORMAT:-mp3_44100_128}"
  
  if [[ -z "$output" ]]; then
    local ext
    ext=$(get_extension_from_format "$format")
    output=$(get_default_output "tts" "$ext")
    log_debug "Auto-generated output filename: ${output}"
  fi
  
  ensure_output_dir "$output"
  args+=("--output" "$output")
  
  # Add voice settings if provided
  if [[ -n "${INPUT_STABILITY:-}" ]]; then
    args+=("--stability" "$INPUT_STABILITY")
  fi
  
  if [[ -n "${INPUT_SIMILARITY_BOOST:-}" ]]; then
    args+=("--similarity-boost" "$INPUT_SIMILARITY_BOOST")
  fi
  
  if [[ -n "${INPUT_STYLE:-}" ]] && [[ "$INPUT_STYLE" != "0" ]]; then
    args+=("--style" "$INPUT_STYLE")
  fi
  
  if [[ "$(parse_bool "${INPUT_SPEAKER_BOOST:-true}")" == "true" ]]; then
    args+=("--speaker-boost")
  fi
  
  if [[ -n "${INPUT_LANGUAGE:-}" ]]; then
    args+=("--language" "$INPUT_LANGUAGE")
  fi
  
  if [[ -n "${INPUT_SEED:-}" ]]; then
    args+=("--seed" "$INPUT_SEED")
  fi
  
  # Execute with retry
  log_info "Generating speech..."
  log_debug "Command: ${cli} ${args[*]}"
  
  local retry_count="${INPUT_RETRY_COUNT:-3}"
  retry_command "$retry_count" 5 run_cli "${args[@]}"
  
  # Verify output
  if [[ ! -f "$output" ]]; then
    log_error "Output file was not created: ${output}"
    exit 1
  fi
  
  local file_size
  file_size=$(stat -f%z "$output" 2>/dev/null || stat -c%s "$output" 2>/dev/null || echo "unknown")
  log_info "Generated audio: ${output} (${file_size} bytes)"
  
  set_output "output-file" "$output"
}
