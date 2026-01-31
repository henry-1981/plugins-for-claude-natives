# Gmail Plugin

Multi-account Gmail integration with email reading, searching, sending, and management.

## Features

- Query multiple Google accounts (work, personal) in parallel
- Search emails with Gmail query syntax
- Send emails with attachments, HTML support
- Manage labels, drafts, and message status
- OAuth2 authentication with stored refresh tokens

## Installation

```bash
/plugin install gmail
```

## Prerequisites

### Option 1: Claude in Chrome (Recommended for Non-Developers)

If you don't have gcloud CLI set up, Claude can help you configure Google Cloud Console through browser automation:

1. Tell Claude: "Help me set up Gmail API credentials using Claude in Chrome"
2. Claude will guide you through:
   - Creating a Google Cloud project
   - Enabling Gmail API
   - Creating OAuth 2.0 credentials
   - Downloading credentials.json

### Option 2: Manual Setup

1. Create a project at [Google Cloud Console](https://console.cloud.google.com)
2. Enable Gmail API
3. Create OAuth 2.0 Client ID (Desktop type)
4. Download `credentials.json` → save to `references/credentials.json`

### Account Authentication (one-time)

```bash
# Work account
uv run python scripts/setup_auth.py --account work

# Personal account
uv run python scripts/setup_auth.py --account personal
```

### Alternative: gcloud ADC

```bash
gcloud auth application-default login \
    --scopes=https://www.googleapis.com/auth/gmail.modify,https://www.googleapis.com/auth/gmail.send,https://www.googleapis.com/auth/gmail.labels
```

Use `--adc` flag when running scripts.

## Usage

Ask Claude about your email:

- "Check my unread emails"
- "Search for emails from ${SENDER_EMAIL}"
- "Send an email to ${RECIPIENT_EMAIL}"
- "Reply to this email"
- "Mark this email as read"

### Gmail Search Query Examples

| Query | Description |
|-------|-------------|
| `from:user@example.com` | From specific sender |
| `is:unread` | Unread emails |
| `has:attachment` | Has attachments |
| `after:2024/01/01` | After date |
| `newer_than:7d` | Within last 7 days |

## API Scopes

| Scope | Purpose |
|-------|---------|
| `gmail.modify` | Read/modify/delete messages |
| `gmail.send` | Send emails |
| `gmail.labels` | Manage labels |

## License

MIT
