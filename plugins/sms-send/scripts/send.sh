#!/bin/bash
# 단일 SMS/iMessage 발송
# Usage: ./send.sh "010-1234-5678" "메시지 내용"

PHONE="$1"
MESSAGE="$2"

if [ -z "$PHONE" ] || [ -z "$MESSAGE" ]; then
    echo "Usage: $0 <phone_number> <message>"
    exit 1
fi

# 전화번호 정규화 (010-1234-5678 -> +821012345678)
normalize_phone() {
    local phone="$1"
    # 하이픈 제거
    phone="${phone//-/}"
    # 앞에 0이면 +82로 변환
    if [[ "$phone" == 0* ]]; then
        phone="+82${phone:1}"
    elif [[ "$phone" != +* ]]; then
        phone="+82$phone"
    fi
    echo "$phone"
}

NORMALIZED=$(normalize_phone "$PHONE")

osascript <<EOF
tell application "Messages"
    send "$MESSAGE" to buddy "$NORMALIZED"
end tell
EOF

if [ $? -eq 0 ]; then
    echo "발송 완료: $NORMALIZED"
else
    echo "발송 실패: $NORMALIZED"
    exit 1
fi
