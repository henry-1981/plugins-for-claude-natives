# Gmail Plugin

Multi-account Gmail integration with email reading, searching, sending, and management.

## Features

- Query multiple Google accounts (work, personal) in parallel
- Search emails with Gmail query syntax
- Send emails with attachments, HTML support
- Manage labels, drafts, and message status
- 4-step email sending workflow with test delivery
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
cd skills/gmail

# Install dependencies
uv sync

# Authenticate accounts (name them as you like)
uv run python scripts/setup_auth.py --account work
uv run python scripts/setup_auth.py --account personal
```

Browser will open for Google login → refresh token saved to `accounts/{name}.json`

### Alternative: gcloud ADC

```bash
gcloud auth application-default login \
    --scopes=https://www.googleapis.com/auth/gmail.modify,https://www.googleapis.com/auth/gmail.send,https://www.googleapis.com/auth/gmail.labels
```

Use `--adc` flag when running scripts.

## Usage

Ask Claude about your email:

- "Check my unread emails"
- "Search for emails from boss@company.com"
- "Send an email to colleague@company.com"
- "Reply to this email"
- "Mark this email as read"

## CLI Scripts

This plugin provides 5 CLI scripts for different operations:

### Script Overview

| Script | Purpose | When to Use |
|--------|---------|-------------|
| `list_messages.py` | Search/list emails | "What emails do I have?" |
| `read_message.py` | Read single email/thread | "Show me this email's full content" |
| `send_message.py` | Send/reply emails | "Send an email to..." |
| `manage_labels.py` | Labels, drafts, status | "Mark as read", "Add label" |
| `setup_auth.py` | Account authentication | One-time setup |

### list_messages.py - Search & List

Search and list emails with query filters. Shows **summary** (subject, from, snippet).

```bash
# Recent 10 emails
uv run python scripts/list_messages.py --account work --max 10

# Unread emails
uv run python scripts/list_messages.py --account work --query "is:unread"

# From specific sender
uv run python scripts/list_messages.py --account work --query "from:boss@company.com"

# With date range
uv run python scripts/list_messages.py --account work --query "after:2024/01/01 before:2024/12/31"

# Filter by labels
uv run python scripts/list_messages.py --account work --labels INBOX,IMPORTANT

# Show full content (truncated to 500 chars)
uv run python scripts/list_messages.py --account work --full

# JSON output
uv run python scripts/list_messages.py --account work --json
```

### read_message.py - Read Full Content

Read **single message** or **entire thread** with full body. Supports attachment download.

```bash
# Read single message
uv run python scripts/read_message.py --account work --id <message_id>

# Read entire thread
uv run python scripts/read_message.py --account work --thread <thread_id>

# Download attachments
uv run python scripts/read_message.py --account work --id <message_id> --save-attachments ./downloads

# JSON output
uv run python scripts/read_message.py --account work --id <message_id> --json
```

### list vs read - When to Use Which?

| Scenario | Use This |
|----------|----------|
| "What emails came today?" | `list_messages.py --query "newer_than:1d"` |
| "Show me emails from John" | `list_messages.py --query "from:john@..."` |
| "Read this email in full" | `read_message.py --id <id>` |
| "Show me the whole conversation" | `read_message.py --thread <thread_id>` |
| "Download the attachment" | `read_message.py --id <id> --save-attachments ./` |

**Typical workflow:**
```bash
# 1. Find emails
uv run python scripts/list_messages.py --query "from:boss@company.com"
# → Shows: 📩 [Urgent] Meeting Request (ID: abc123)

# 2. Read the one you want
uv run python scripts/read_message.py --id abc123

# 3. Download attachments if needed
uv run python scripts/read_message.py --id abc123 --save-attachments ./downloads
```

### send_message.py - Send Emails

Send new emails, replies, or save drafts.

```bash
# New email
uv run python scripts/send_message.py --account work \
    --to "recipient@example.com" \
    --subject "Hello" \
    --body "Email content here."

# HTML email
uv run python scripts/send_message.py --account work \
    --to "recipient@example.com" \
    --subject "Newsletter" \
    --body "<h1>Title</h1><p>Content</p>" \
    --html

# With attachments
uv run python scripts/send_message.py --account work \
    --to "recipient@example.com" \
    --subject "Files attached" \
    --body "Please review." \
    --attach file1.pdf,file2.xlsx

# Reply to existing thread
uv run python scripts/send_message.py --account work \
    --to "recipient@example.com" \
    --subject "Re: Original Subject" \
    --body "Reply content" \
    --reply-to <message_id> \
    --thread <thread_id>

# Save as draft
uv run python scripts/send_message.py --account work \
    --to "recipient@example.com" \
    --subject "Draft email" \
    --body "Content" \
    --draft
```

### manage_labels.py - Labels & Message Management

```bash
# List labels
uv run python scripts/manage_labels.py --account work list-labels

# Create label
uv run python scripts/manage_labels.py --account work create-label --name "Project/A"

# Mark as read
uv run python scripts/manage_labels.py --account work mark-read --id <message_id>

# Star/unstar
uv run python scripts/manage_labels.py --account work star --id <message_id>
uv run python scripts/manage_labels.py --account work unstar --id <message_id>

# Archive
uv run python scripts/manage_labels.py --account work archive --id <message_id>

# Trash/untrash
uv run python scripts/manage_labels.py --account work trash --id <message_id>
uv run python scripts/manage_labels.py --account work untrash --id <message_id>

# Modify labels
uv run python scripts/manage_labels.py --account work modify --id <message_id> \
    --add-labels "Label_123,STARRED" --remove-labels "INBOX"

# List drafts
uv run python scripts/manage_labels.py --account work list-drafts

# Send draft
uv run python scripts/manage_labels.py --account work send-draft --draft-id <draft_id>

# View profile
uv run python scripts/manage_labels.py --account work profile
```

## Gmail Search Query Examples

| Query | Description |
|-------|-------------|
| `from:user@example.com` | From specific sender |
| `to:user@example.com` | To specific recipient |
| `subject:project` | Subject contains |
| `is:unread` | Unread emails |
| `is:starred` | Starred emails |
| `has:attachment` | Has attachments |
| `filename:pdf` | PDF attachments |
| `after:2024/01/01` | After date |
| `before:2024/12/31` | Before date |
| `newer_than:7d` | Within last 7 days |
| `older_than:30d` | Older than 30 days |
| `in:inbox` | In inbox |
| `in:sent` | In sent folder |
| `label:work` | Has specific label |

**Combined queries:**
```
from:boss@company.com is:unread after:2024/01/01
has:attachment filename:xlsx newer_than:7d
```

## File Structure

```
skills/gmail/
├── SKILL.md                    # Skill documentation
├── pyproject.toml              # Dependencies
├── scripts/
│   ├── gmail_client.py         # API client library
│   ├── setup_auth.py           # Authentication setup
│   ├── list_messages.py        # List/search emails
│   ├── read_message.py         # Read single email/thread
│   ├── send_message.py         # Send emails
│   └── manage_labels.py        # Labels/drafts management
├── references/
│   └── credentials.json        # OAuth Client ID (gitignore)
└── accounts/                   # Account tokens (gitignore)
    └── {account_name}.json
```

## API Scopes

| Scope | Purpose |
|-------|---------|
| `gmail.modify` | Read/modify/delete messages |
| `gmail.send` | Send emails |
| `gmail.labels` | Manage labels |

## Security Notes

- `accounts/*.json`: Contains refresh tokens - **never commit**
- `references/credentials.json`: Contains client secret - **never commit**
- Both directories are in `.gitignore`

## License

MIT
