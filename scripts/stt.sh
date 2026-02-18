#!/usr/bin/env bash
# STT (Speech-to-Text) operation handler
# SECURITY MANIFEST:
#   Environment variables accessed: INPUT_* variables
#   External endpoints called: api.elevenlabs.io (via CLI)
#   Local files read: INPUT_AUDIO_FILE
#   Local files written: Output transcript file

handle_stt() {
  local cli
  cli=$(get_cli)
  
  # Get audio file
  local audio_file="${INPUT_AUDIO_FILE:-}"
  
  if [[ -z "$audio_file" ]]; then
    log_error "Input 'audio-file' is required for STT"
    exit 1
  fi
  
  check_file_exists "$audio_file"
  log_debug "Processing audio file: ${audio_file}"
  
  # Build command arguments
  local args=()
  args+=("stt")
  args+=("$audio_file")
  
  # Add model
  args+=("--model" "${INPUT_STT_MODEL:-scribe_v1}")
  
  # Add output format
  local format="${INPUT_STT_FORMAT:-txt}"
  args+=("--format" "$format")
  
  # Determine output file
  local output="${INPUT_OUTPUT:-}"
  if [[ -z "$output" ]]; then
    output=$(get_default_output "stt" "$format")
    log_debug "Auto-generated output filename: ${output}"
  fi
  
  ensure_output_dir "$output"
  args+=("--output" "$output")
  
  # Add timestamps
  args+=("--timestamps" "${INPUT_TIMESTAMPS:-word}")
  
  # Add diarization if enabled
  if [[ "$(parse_bool "${INPUT_DIARIZE:-false}")" == "true" ]]; then
    args+=("--diarize")
    
    if [[ -n "${INPUT_NUM_SPEAKERS:-}" ]]; then
      args+=("--num-speakers" "$INPUT_NUM_SPEAKERS")
    fi
  fi
  
  # Add language if specified
  if [[ -n "${INPUT_STT_LANGUAGE:-}" ]]; then
    args+=("--language" "$INPUT_STT_LANGUAGE")
  fi
  
  # Add tag audio events
  if [[ "$(parse_bool "${INPUT_TAG_AUDIO_EVENTS:-true}")" == "true" ]]; then
    args+=("--tag-audio-events" "true")
  else
    args+=("--tag-audio-events" "false")
  fi
  
  # Execute with retry
  log_info "Transcribing audio..."
  log_debug "Command: ${cli} ${args[*]}"
  
  local retry_count="${INPUT_RETRY_COUNT:-3}"
  retry_command "$retry_count" 5 run_cli "${args[@]}"
  
  # Verify output and read transcript
  if [[ ! -f "$output" ]]; then
    log_error "Output file was not created: ${output}"
    exit 1
  fi
  
  local transcript
  transcript=$(cat "$output")
  
  log_info "Transcript saved to: ${output}"
  log_debug "Transcript preview: ${transcript:0:100}..."
  
  set_output "output-file" "$output"
  set_output "transcript" "$transcript"
}
