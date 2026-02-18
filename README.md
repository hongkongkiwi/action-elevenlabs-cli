<h1 align="center">🎙️ ElevenLabs CLI GitHub Action</h1>

<p align="center">
  <strong>Use ElevenLabs AI audio capabilities in your GitHub workflows</strong>
</p>

<p align="center">
  <a href="https://github.com/hongkongkiwi/elevenlabs-cli/releases">
    <img src="https://img.shields.io/github/v/release/hongkongkiwi/elevenlabs-cli?style=flat-square&logo=github" alt="Release">
  </a>
  <a href="https://github.com/hongkongkiwi/action-elevenlabs-cli/actions">
    <img src="https://img.shields.io/github/actions/workflow/status/hongkongkiwi/action-elevenlabs-cli/ci.yml?style=flat-square&logo=github" alt="CI">
  </a>
  <a href="https://opensource.org/licenses/MIT">
    <img src="https://img.shields.io/badge/License-MIT-blue?style=flat-square" alt="License">
  </a>
</p>

---

> **Unofficial Action**: This is an independent, community-built GitHub Action. It is not officially released by ElevenLabs.

---

## Features

| Operation | Description |
|-----------|-------------|
| 🗣️ **TTS** | Convert text to speech with 100+ voices |
| 🎧 **STT** | Transcribe audio with speaker diarization & subtitles |
| 📚 **Knowledge** | Manage ElevenLabs knowledge base documents |
| 🔄 **RAG** | Create and manage RAG indexes |
| 📊 **Usage** | Monitor API usage and set alerts |

## Quick Start

```yaml
name: Generate Audio
on:
  release:
    types: [published]

jobs:
  audio:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      
      - uses: hongkongkiwi/action-elevenlabs-cli@v0.1.6
        with:
          operation: tts
          api-key: ${{ secrets.ELEVENLABS_API_KEY }}
          text: "Release published!"
          voice: Brian
          output: audio/release.mp3
      
      - uses: actions/upload-artifact@v4
        with:
          name: release-audio
          path: audio/release.mp3
```

## Prerequisites

- **ElevenLabs API key** - Get one free at [ElevenLabs API Keys](https://elevenlabs.io/app/settings/api-keys)
- Add `ELEVENLABS_API_KEY` to your repository secrets

## Operations

### Text-to-Speech (TTS)

Convert text to natural speech.

```yaml
- uses: hongkongkiwi/action-elevenlabs-cli@v0.1.6
  with:
    operation: tts
    api-key: ${{ secrets.ELEVENLABS_API_KEY }}
    
    # Text input (required - use text or text-file)
    text: "Hello, world!"
    # text-file: script.md
    
    # Voice settings
    voice: Brian              # Voice name or ID
    model: eleven_multilingual_v2
    output-format: mp3_44100_128
    stability: 0.5
    similarity-boost: 0.75
    style: 0
    speaker-boost: true
    
    # Output
    output: audio/output.mp3  # Auto-generated if not specified
```

**Supported Voices**: Brian, Rachel, Domi, Antoni, Elli, Josh, Arnold, Adam, Sam, and 100+ more. See [ElevenLabs Voice Library](https://elevenlabs.io/app/voice-library).

**Models**:
| Model | Best For |
|-------|----------|
| `eleven_multilingual_v2` | High quality, 29 languages (default) |
| `eleven_flash_v2_5` | Lowest latency |
| `eleven_v3` | Expressive, emotional speech |

**Output Formats**:
| Format | Use Case |
|--------|----------|
| `mp3_44100_128` | Default, good compatibility |
| `mp3_44100_192` | Higher quality MP3 |
| `wav_44100` | Uncompressed, editing |
| `opus_48000_128` | Streaming, WebRTC |

### Speech-to-Text (STT)

Transcribe audio with timestamps and speaker identification.

```yaml
- uses: hongkongkiwi/action-elevenlabs-cli@v0.1.6
  with:
    operation: stt
    api-key: ${{ secrets.ELEVENLABS_API_KEY }}
    
    # Audio input (required)
    audio-file: recording.mp3
    
    # Transcription settings
    stt-model: scribe_v1      # or scribe_v1_base
    diarize: true             # Identify speakers
    num-speakers: 3           # Expected speakers
    timestamps: word          # none, word, or character
    stt-language: en          # Auto-detected if not specified
    
    # Output
    stt-format: srt           # txt, json, srt, vtt
    output: subtitles/recording.srt
```

**STT Models**:
| Model | Description |
|-------|-------------|
| `scribe_v1` | High accuracy (default) |
| `scribe_v1_base` | Faster, lower cost |

### Knowledge Base

Manage documents for RAG (Retrieval-Augmented Generation).

```yaml
# Add document from file
- uses: hongkongkiwi/action-elevenlabs-cli@v0.1.6
  with:
    operation: knowledge
    api-key: ${{ secrets.ELEVENLABS_API_KEY }}
    knowledge-action: add-file
    document-file: docs/api.md
    document-name: "API Documentation"

# Add document from URL
- uses: hongkongkiwi/action-elevenlabs-cli@v0.1.6
  with:
    operation: knowledge
    api-key: ${{ secrets.ELEVENLABS_API_KEY }}
    knowledge-action: add-url
    document-url: https://example.com/docs
    document-name: "External Docs"

# List documents
- uses: hongkongkiwi/action-elevenlabs-cli@v0.1.6
  with:
    operation: knowledge
    api-key: ${{ secrets.ELEVENLABS_API_KEY }}
    knowledge-action: list

# Delete document
- uses: hongkongkiwi/action-elevenlabs-cli@v0.1.6
  with:
    operation: knowledge
    api-key: ${{ secrets.ELEVENLABS_API_KEY }}
    knowledge-action: delete
    document-id: doc_abc123
```

**Knowledge Actions**:
| Action | Required Inputs |
|--------|-----------------|
| `add-file` | `document-file`, `document-name` |
| `add-url` | `document-url`, `document-name` |
| `add-text` | `document-text`, `document-name` |
| `list` | None |
| `get` | `document-id` |
| `delete` | `document-id` |

### RAG Indexes

Create and manage RAG indexes for knowledge retrieval.

```yaml
# Create RAG index
- uses: hongkongkiwi/action-elevenlabs-cli@v0.1.6
  id: rag
  with:
    operation: rag
    api-key: ${{ secrets.ELEVENLABS_API_KEY }}
    rag-action: create
    rag-document-ids: doc_abc123,doc_def456

# Use the output
- run: echo "RAG Index ID: ${{ steps.rag.outputs.rag-index-id }}"

# Check RAG status
- uses: hongkongkiwi/action-elevenlabs-cli@v0.1.6
  with:
    operation: rag
    api-key: ${{ secrets.ELEVENLABS_API_KEY }}
    rag-action: status
    rag-index-id: rag_xyz789
```

### Usage Monitoring

Check API usage and get alerts.

```yaml
- uses: hongkongkiwi/action-elevenlabs-cli@v0.1.6
  with:
    operation: usage
    api-key: ${{ secrets.ELEVENLABS_API_KEY }}
    usage-threshold: 80  # Warn if usage >= 80%
```

## Inputs Reference

| Input | Required | Default | Description |
|-------|----------|---------|-------------|
| `operation` | ✅ | - | Operation: `tts`, `stt`, `knowledge`, `rag`, `usage` |
| `api-key` | ✅ | - | ElevenLabs API key |
| `voice` | | `Brian` | Voice name or ID |
| `model` | | `eleven_multilingual_v2` | TTS model |
| `output-format` | | `mp3_44100_128` | Audio format |
| `stability` | | `0.5` | Voice stability (0-1) |
| `similarity-boost` | | `0.75` | Similarity boost (0-1) |
| `style` | | `0` | Style/exaggeration (0-1) |
| `speaker-boost` | | `true` | Enhance clarity |
| `stt-model` | | `scribe_v1` | STT model |
| `diarize` | | `false` | Speaker diarization |
| `timestamps` | | `word` | Timestamp granularity |
| `stt-format` | | `txt` | STT output format |
| `output` | | *(auto)* | Output file path |
| `timeout` | | `300` | Timeout in seconds |
| `retry-count` | | `3` | Retries on failure |
| `verbose` | | `false` | Enable debug output |

## Outputs Reference

| Output | Description |
|--------|-------------|
| `output-file` | Path to generated output file |
| `transcript` | Transcription text (STT) |
| `usage-info` | Usage statistics JSON (usage) |
| `document-id` | Created document ID (knowledge) |
| `rag-index-id` | RAG index ID (RAG create) |
| `voice-id` | Resolved voice ID (TTS) |

## Example Workflows

### Generate Audio Changelog on Release

```yaml
name: Audio Changelog
on:
  release:
    types: [published]

jobs:
  audio:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      
      - uses: hongkongkiwi/action-elevenlabs-cli@v0.1.6
        with:
          operation: tts
          api-key: ${{ secrets.ELEVENLABS_API_KEY }}
          text-file: CHANGELOG.md
          voice: Brian
          output: audio/changelog.mp3
      
      - uses: actions/upload-artifact@v4
        with:
          name: changelog-audio
          path: audio/changelog.mp3
```

### Transcribe Meeting Recordings

```yaml
name: Transcribe Meetings
on:
  push:
    paths: ['recordings/*.mp3']

jobs:
  transcribe:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      
      - uses: hongkongkiwi/action-elevenlabs-cli@v0.1.6
        with:
          operation: stt
          api-key: ${{ secrets.ELEVENLABS_API_KEY }}
          audio-file: recordings/meeting.mp3
          diarize: true
          stt-format: srt
          output: subtitles/meeting.srt
      
      - uses: actions/upload-artifact@v4
        with:
          name: subtitles
          path: subtitles/
```

### Weekly Usage Report

```yaml
name: Usage Report
on:
  schedule:
    - cron: '0 9 * * 1'  # Monday 9am UTC

jobs:
  report:
    runs-on: ubuntu-latest
    steps:
      - uses: hongkongkiwi/action-elevenlabs-cli@v0.1.6
        id: usage
        with:
          operation: usage
          api-key: ${{ secrets.ELEVENLABS_API_KEY }}
          usage-threshold: 75
      
      - name: Log usage
        run: echo "Usage info: ${{ steps.usage.outputs.usage-info }}"
```

## Versioning

This action uses the same version as the ElevenLabs CLI:

- `@v0.1.6` - Use CLI version 0.1.6
- `@v0.1.7` - Use CLI version 0.1.7
- etc.

The action automatically downloads the matching CLI version for your platform.

## Security

- API keys should be stored as [GitHub Secrets](https://docs.github.com/en/actions/security-guides/encrypted-secrets)
- API keys are only sent to `api.elevenlabs.io`
- Audio/text content is sent to ElevenLabs for processing
- No data is sent to third parties

## Related Projects

| Project | Description |
|---------|-------------|
| [elevenlabs-cli](https://github.com/hongkongkiwi/elevenlabs-cli) | Main CLI repository |
| [homebrew-elevenlabs-cli](https://github.com/hongkongkiwi/homebrew-elevenlabs-cli) | Homebrew tap |
| [scoop-elevenlabs-cli](https://github.com/hongkongkiwi/scoop-elevenlabs-cli) | Scoop bucket |
| [skill-elevenlabs-cli](https://github.com/hongkongkiwi/skill-elevenlabs-cli) | ClawHub skill |

## Resources

- [ElevenLabs API Reference](https://elevenlabs.io/docs/api-reference)
- [ElevenLabs Documentation](https://elevenlabs.io/docs)
- [API Keys](https://elevenlabs.io/app/settings/api-keys)

## License

MIT License - see [LICENSE](LICENSE) for details.
