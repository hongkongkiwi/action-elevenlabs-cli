#!/usr/bin/env bash
# Install ElevenLabs CLI binary
# SECURITY MANIFEST:
#   Environment variables accessed: RUNNER_OS, RUNNER_ARCH, GITHUB_ACTION_REF, INPUT_VERBOSE
#   External endpoints called: https://github.com/hongkongkiwi/elevenlabs-cli/releases/*
#   Local files read: none
#   Local files written: /usr/local/bin/elevenlabs (or temp dir on Windows)

set -euo pipefail

VERBOSE="${INPUT_VERBOSE:-false}"
ACTION_REF="${GITHUB_ACTION_REF:-latest}"

log() {
  if [[ "$VERBOSE" == "true" ]]; then
    echo "[install-cli] $*"
  fi
}

log "Installing ElevenLabs CLI..."
log "Runner OS: ${RUNNER_OS}"
log "Runner Arch: ${RUNNER_ARCH}"
log "Action Ref: ${ACTION_REF}"

# Determine OS
case "${RUNNER_OS}" in
  Linux)
    OS="linux"
    ;;
  macOS)
    OS="darwin"
    ;;
  Windows)
    OS="windows"
    ;;
  *)
    echo "::error::Unsupported OS: ${RUNNER_OS}"
    exit 1
    ;;
esac

# Determine Architecture
case "${RUNNER_ARCH}" in
  X64|x64|amd64|AMD64)
    ARCH="x86_64"
    ;;
  ARM64|arm64|aarch64)
    ARCH="aarch64"
    ;;
  *)
    echo "::error::Unsupported architecture: ${RUNNER_ARCH}"
    exit 1
    ;;
esac

# Determine version from action ref
# Action tag matches CLI version (e.g., v0.1.6)
if [[ "$ACTION_REF" == "latest" ]] || [[ "$ACTION_REF" == "refs/heads/main" ]] || [[ -z "$ACTION_REF" ]]; then
  # For testing/unversioned use, get latest
  CLI_VERSION="latest"
  DOWNLOAD_URL="https://github.com/hongkongkiwi/elevenlabs-cli/releases/latest/download/elevenlabs-cli-${OS}-${ARCH}"
else
  # Extract version from ref (handles both "v0.1.6" and "refs/tags/v0.1.6")
  CLI_VERSION="${ACTION_REF#refs/tags/}"
  CLI_VERSION="${CLI_VERSION#refs/heads/}"
  DOWNLOAD_URL="https://github.com/hongkongkiwi/elevenlabs-cli/releases/download/${CLI_VERSION}/elevenlabs-cli-${OS}-${ARCH}"
fi

# On Windows, add .exe extension
if [[ "$OS" == "windows" ]]; then
  DOWNLOAD_URL="${DOWNLOAD_URL}.exe"
  BINARY_NAME="elevenlabs.exe"
else
  BINARY_NAME="elevenlabs"
fi

log "CLI Version: ${CLI_VERSION}"
log "Download URL: ${DOWNLOAD_URL}"

# Download binary
echo "Downloading ElevenLabs CLI ${CLI_VERSION} for ${OS}-${ARCH}..."

TEMP_DIR="${RUNNER_TEMP:-/tmp}"
BINARY_PATH="${TEMP_DIR}/${BINARY_NAME}"

if ! curl -fsSL --retry 3 --retry-delay 5 -o "${BINARY_PATH}" "${DOWNLOAD_URL}"; then
  echo "::error::Failed to download CLI from ${DOWNLOAD_URL}"
  echo "::error::Make sure version ${CLI_VERSION} exists and has a binary for ${OS}-${ARCH}"
  exit 1
fi

# Make executable (not needed on Windows)
if [[ "$OS" != "windows" ]]; then
  chmod +x "${BINARY_PATH}"
fi

# Move to a standard location
INSTALL_DIR="${RUNNER_TOOL_CACHE:-/usr/local/bin}"
mkdir -p "${INSTALL_DIR}"

if [[ "$OS" == "windows" ]]; then
  INSTALL_PATH="${INSTALL_DIR}/${BINARY_NAME}"
else
  INSTALL_PATH="${INSTALL_DIR}/elevenlabs"
fi

mv "${BINARY_PATH}" "${INSTALL_PATH}"

# Add to PATH for subsequent steps
echo "${INSTALL_DIR}" >> "${GITHUB_PATH}"

# Verify installation
log "Verifying installation..."
if ! "${INSTALL_PATH}" --version 2>/dev/null; then
  log "CLI installed but --version not available (older version)"
fi

echo "ElevenLabs CLI installed successfully to ${INSTALL_PATH}"

# Export for use in other scripts
echo "ELEVENLABS_CLI_PATH=${INSTALL_PATH}" >> "${GITHUB_ENV}"
