#!/usr/bin/env bash
# Main operation router for ElevenLabs CLI Action
# SECURITY MANIFEST:
#   Environment variables accessed: All INPUT_* variables
#   External endpoints called: via elevenlabs CLI only
#   Local files read: Files specified by user inputs
#   Local files written: Output files specified by user

set -euo pipefail

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Source utilities
source "${SCRIPT_DIR}/utils.sh"

# Source operation handlers
source "${SCRIPT_DIR}/tts.sh"
source "${SCRIPT_DIR}/stt.sh"
source "${SCRIPT_DIR}/knowledge.sh"
source "${SCRIPT_DIR}/usage.sh"

log_info "ElevenLabs CLI Action starting..."
log_debug "Operation: ${INPUT_OPERATION}"
log_debug "API Key: ${INPUT_API_KEY:+[set]}"

# Validate required inputs
require_input "api-key" "${INPUT_API_KEY:-}"
require_input "operation" "${INPUT_OPERATION:-}"

# Set API key as environment variable for CLI
export ELEVENLABS_API_KEY="${INPUT_API_KEY}"

# Route to appropriate handler
case "${INPUT_OPERATION}" in
  tts)
    log_info "Running Text-to-Speech operation..."
    handle_tts
    ;;
  stt)
    log_info "Running Speech-to-Text operation..."
    handle_stt
    ;;
  knowledge)
    log_info "Running Knowledge Base operation..."
    handle_knowledge
    ;;
  rag)
    log_info "Running RAG operation..."
    handle_rag
    ;;
  usage)
    log_info "Running Usage operation..."
    handle_usage
    ;;
  *)
    log_error "Unknown operation: ${INPUT_OPERATION}"
    log_error "Supported operations: tts, stt, knowledge, rag, usage"
    exit 1
    ;;
esac

log_info "Operation completed successfully"
