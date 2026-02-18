# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [0.1.6] - 2026-02-18

### Added
- Initial release of ElevenLabs CLI GitHub Action
- **TTS Operation**: Text-to-speech with 100+ voices
  - Voice name resolution (e.g., "Brian" → voice_id)
  - Voice settings: stability, similarity-boost, style, speaker-boost
  - Multiple output formats (MP3, WAV, Opus, PCM)
  - Support for text input or text file input
  - Language specification for multilingual models
  - Seed for reproducible output
- **STT Operation**: Speech-to-text transcription
  - Speaker diarization (identify different speakers)
  - Multiple output formats (TXT, JSON, SRT, VTT)
  - Word-level or character-level timestamps
  - Audio event tagging
- **Knowledge Operation**: Knowledge base management
  - Add documents from file, URL, or text
  - List, get, and delete documents
- **RAG Operation**: RAG index management
  - Create indexes from document IDs
  - Status check and delete
- **Usage Operation**: API usage monitoring
  - Threshold-based warnings
  - Usage statistics output
- CI workflow with shellcheck linting
- Release workflow for GitHub releases
- Comprehensive documentation with examples

### Security
- API key passed via environment variable, never logged
- All external calls go through ElevenLabs CLI to api.elevenlabs.io only
- Security manifest headers in all scripts

[Unreleased]: https://github.com/hongkongkiwi/action-elevenlabs-cli/compare/v0.1.6...HEAD
[0.1.6]: https://github.com/hongkongkiwi/action-elevenlabs-cli/releases/tag/v0.1.6
