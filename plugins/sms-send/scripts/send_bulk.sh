#!/bin/bash
# 대량 SMS/iMessage 발송 (CSV 기반)
# Usage: ./send_bulk.sh recipients.csv "메시지 내용"
# CSV 형식: 이름,전화번호 (헤더 포함)

CSV_FILE="$1"
MESSAGE="$2"

if [ -z "$CSV_FILE" ] || [ -z "$MESSAGE" ]; then
    echo "Usage: $0 <csv_file> <message>"
    echo "CSV format: 이름,전화번호"
    exit 1
fi

if [ ! -f "$CSV_FILE" ]; then
    echo "Error: File not found: $CSV_FILE"
    exit 1
fi

# 전화번호 정규화
normalize_phone() {
    local phone="$1"
    phone="${phone//-/}"
    if [[ "$phone" == 0* ]]; then
        phone="+82${phone:1}"
    elif [[ "$phone" != +* ]]; then
        phone="+82$phone"
    fi
    echo "$phone"
}

# 발송 카운터
SUCCESS=0
FAIL=0
TOTAL=0

# CSV 읽기 (헤더 스킵)
tail -n +2 "$CSV_FILE" | while IFS=',' read -r name phone rest; do
    # 빈 줄 스킵
    [ -z "$phone" ] && continue

    TOTAL=$((TOTAL + 1))
    NORMALIZED=$(normalize_phone "$phone")

    osascript <<EOF
tell application "Messages"
    send "$MESSAGE" to buddy "$NORMALIZED"
end tell
EOF

    if [ $? -eq 0 ]; then
        echo "[$TOTAL] 발송 완료: $name ($NORMALIZED)"
        SUCCESS=$((SUCCESS + 1))
    else
        echo "[$TOTAL] 발송 실패: $name ($NORMALIZED)"
        FAIL=$((FAIL + 1))
    fi

    # 발송 간격
    sleep 0.5
done

echo ""
echo "=== 발송 완료 ==="
echo "성공: $SUCCESS / 실패: $FAIL"
