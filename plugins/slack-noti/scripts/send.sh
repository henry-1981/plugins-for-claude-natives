#!/bin/bash
# Slack 알림 발송 스크립트
# Usage: ./send.sh "메시지 내용" [채널명]

set -e

# .env 파일 로드 (프로젝트 루트 기준)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../../../../" && pwd)"

if [ -f "$PROJECT_ROOT/.env" ]; then
    set -a
    source "$PROJECT_ROOT/.env"
    set +a
fi

MESSAGE="$1"
CHANNEL="${2:-noti-cc}"

if [ -z "$MESSAGE" ]; then
    echo "Usage: $0 \"메시지\" [채널명]"
    echo "Example: $0 \"[작업 완료] PR 생성됨\""
    exit 1
fi

if [ -z "$SLACK_BOT_TOKEN" ]; then
    echo "Error: SLACK_BOT_TOKEN 환경변수가 설정되지 않았습니다."
    exit 1
fi

# Slack API로 메시지 발송
RESPONSE=$(curl -s -X POST "https://slack.com/api/chat.postMessage" \
    -H "Authorization: Bearer $SLACK_BOT_TOKEN" \
    -H "Content-Type: application/json" \
    -d "{
        \"channel\": \"#${CHANNEL}\",
        \"text\": \"${MESSAGE}\",
        \"unfurl_links\": false
    }")

# 결과 확인
OK=$(echo "$RESPONSE" | grep -o '"ok":true' || true)

if [ -n "$OK" ]; then
    echo "Sent to #${CHANNEL}"
else
    ERROR=$(echo "$RESPONSE" | grep -o '"error":"[^"]*"' || echo "Unknown error")
    echo "Failed: $ERROR"
    exit 1
fi
