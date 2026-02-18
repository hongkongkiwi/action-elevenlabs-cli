#!/usr/bin/env bash
# Knowledge Base and RAG operation handler
# SECURITY MANIFEST:
#   Environment variables accessed: INPUT_* variables
#   External endpoints called: api.elevenlabs.io (via CLI)
#   Local files read: INPUT_DOCUMENT_FILE if specified
#   Local files written: None

handle_knowledge() {
  local cli
  cli=$(get_cli)
  
  local action="${INPUT_KNOWLEDGE_ACTION:-add-file}"
  log_debug "Knowledge action: ${action}"
  
  case "$action" in
    add-url)
      handle_knowledge_add_url
      ;;
    add-file)
      handle_knowledge_add_file
      ;;
    add-text)
      handle_knowledge_add_text
      ;;
    list)
      handle_knowledge_list
      ;;
    get)
      handle_knowledge_get
      ;;
    delete)
      handle_knowledge_delete
      ;;
    *)
      log_error "Unknown knowledge action: ${action}"
      log_error "Supported actions: add-url, add-file, add-text, list, get, delete"
      exit 1
      ;;
  esac
}

handle_knowledge_add_url() {
  local url="${INPUT_DOCUMENT_URL:-}"
  
  if [[ -z "$url" ]]; then
    log_error "Input 'document-url' is required for add-url action"
    exit 1
  fi
  
  require_input "document-name" "${INPUT_DOCUMENT_NAME:-}"
  
  local args=()
  args+=("knowledge" "add-from-url")
  args+=("--url" "$url")
  args+=("--name" "$INPUT_DOCUMENT_NAME")
  
  if [[ -n "${INPUT_DOCUMENT_DESCRIPTION:-}" ]]; then
    args+=("--description" "$INPUT_DOCUMENT_DESCRIPTION")
  fi
  
  log_info "Adding document from URL: ${url}"
  log_debug "Command: ${cli} ${args[*]}"
  
  local result
  result=$(run_cli "${args[@]}" 2>&1)
  
  echo "$result"
  
  # Extract document ID from output
  local doc_id
  doc_id=$(echo "$result" | grep -oP 'document_id["\s:]+\K[^,}]+' | head -1)
  
  if [[ -n "$doc_id" ]]; then
    set_output "document-id" "$doc_id"
    log_info "Document added with ID: ${doc_id}"
  fi
}

handle_knowledge_add_file() {
  local file="${INPUT_DOCUMENT_FILE:-}"
  
  if [[ -z "$file" ]]; then
    log_error "Input 'document-file' is required for add-file action"
    exit 1
  fi
  
  check_file_exists "$file"
  
  local args=()
  args+=("knowledge" "add-from-file")
  args+=("--file" "$file")
  
  if [[ -n "${INPUT_DOCUMENT_NAME:-}" ]]; then
    args+=("--name" "$INPUT_DOCUMENT_NAME")
  fi
  
  if [[ -n "${INPUT_DOCUMENT_DESCRIPTION:-}" ]]; then
    args+=("--description" "$INPUT_DOCUMENT_DESCRIPTION")
  fi
  
  log_info "Adding document from file: ${file}"
  log_debug "Command: ${cli} ${args[*]}"
  
  local result
  result=$(run_cli "${args[@]}" 2>&1)
  
  echo "$result"
  
  # Extract document ID from output
  local doc_id
  doc_id=$(echo "$result" | grep -oP 'document_id["\s:]+\K[^,}]+' | head -1)
  
  if [[ -n "$doc_id" ]]; then
    set_output "document-id" "$doc_id"
    log_info "Document added with ID: ${doc_id}"
  fi
}

handle_knowledge_add_text() {
  local text="${INPUT_DOCUMENT_TEXT:-}"
  
  if [[ -z "$text" ]]; then
    log_error "Input 'document-text' is required for add-text action"
    exit 1
  fi
  
  require_input "document-name" "${INPUT_DOCUMENT_NAME:-}"
  
  local args=()
  args+=("knowledge" "add-from-text")
  args+=("--text" "$text")
  args+=("--name" "$INPUT_DOCUMENT_NAME")
  
  if [[ -n "${INPUT_DOCUMENT_DESCRIPTION:-}" ]]; then
    args+=("--description" "$INPUT_DOCUMENT_DESCRIPTION")
  fi
  
  log_info "Adding document from text..."
  log_debug "Command: ${cli} ${args[*]}"
  
  local result
  result=$(run_cli "${args[@]}" 2>&1)
  
  echo "$result"
  
  # Extract document ID from output
  local doc_id
  doc_id=$(echo "$result" | grep -oP 'document_id["\s:]+\K[^,}]+' | head -1)
  
  if [[ -n "$doc_id" ]]; then
    set_output "document-id" "$doc_id"
    log_info "Document added with ID: ${doc_id}"
  fi
}

handle_knowledge_list() {
  local args=()
  args+=("knowledge" "list")
  
  log_info "Listing knowledge documents..."
  
  run_cli "${args[@]}"
}

handle_knowledge_get() {
  local doc_id="${INPUT_DOCUMENT_ID:-}"
  
  if [[ -z "$doc_id" ]]; then
    log_error "Input 'document-id' is required for get action"
    exit 1
  fi
  
  local args=()
  args+=("knowledge" "get" "$doc_id")
  
  log_info "Getting document: ${doc_id}"
  
  run_cli "${args[@]}"
}

handle_knowledge_delete() {
  local doc_id="${INPUT_DOCUMENT_ID:-}"
  
  if [[ -z "$doc_id" ]]; then
    log_error "Input 'document-id' is required for delete action"
    exit 1
  fi
  
  local args=()
  args+=("knowledge" "delete" "$doc_id")
  
  log_info "Deleting document: ${doc_id}"
  
  run_cli "${args[@]}"
  
  log_info "Document deleted: ${doc_id}"
}

handle_rag() {
  local cli
  cli=$(get_cli)
  
  local action="${INPUT_RAG_ACTION:-status}"
  log_debug "RAG action: ${action}"
  
  case "$action" in
    create)
      handle_rag_create
      ;;
    status)
      handle_rag_status
      ;;
    delete)
      handle_rag_delete
      ;;
    *)
      log_error "Unknown RAG action: ${action}"
      log_error "Supported actions: create, status, delete"
      exit 1
      ;;
  esac
}

handle_rag_create() {
  local doc_ids="${INPUT_RAG_DOCUMENT_IDS:-}"
  
  if [[ -z "$doc_ids" ]]; then
    log_error "Input 'rag-document-ids' is required for RAG create"
    exit 1
  fi
  
  local args=()
  args+=("rag" "create")
  args+=("--document-ids" "$doc_ids")
  
  log_info "Creating RAG index from documents: ${doc_ids}"
  log_debug "Command: ${cli} ${args[*]}"
  
  local result
  result=$(run_cli "${args[@]}" 2>&1)
  
  echo "$result"
  
  # Extract RAG index ID from output
  local rag_id
  rag_id=$(echo "$result" | grep -oP 'rag_id["\s:]+\K[^,}]+' | head -1)
  
  if [[ -n "$rag_id" ]]; then
    set_output "rag-index-id" "$rag_id"
    log_info "RAG index created with ID: ${rag_id}"
  fi
}

handle_rag_status() {
  local rag_id="${INPUT_RAG_INDEX_ID:-}"
  
  if [[ -z "$rag_id" ]]; then
    log_error "Input 'rag-index-id' is required for RAG status"
    exit 1
  fi
  
  local args=()
  args+=("rag" "status" "$rag_id")
  
  log_info "Getting RAG index status: ${rag_id}"
  
  run_cli "${args[@]}"
}

handle_rag_delete() {
  local rag_id="${INPUT_RAG_INDEX_ID:-}"
  
  if [[ -z "$rag_id" ]]; then
    log_error "Input 'rag-index-id' is required for RAG delete"
    exit 1
  fi
  
  local args=()
  args+=("rag" "delete" "$rag_id")
  
  log_info "Deleting RAG index: ${rag_id}"
  
  run_cli "${args[@]}"
  
  log_info "RAG index deleted: ${rag_id}"
}
