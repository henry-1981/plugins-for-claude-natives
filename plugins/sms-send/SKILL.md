---
name: sms-send
description: macOS Messages 앱으로 iMessage/SMS 개별 발송. "문자 보내줘", "SMS 발송", "메시지 전송" 요청에 사용. 수신자별 개별 발송으로 프라이버시 보장.
---

# SMS Send

macOS Messages 앱을 통해 iMessage 또는 SMS를 개별 발송한다.

## 발송 방식

| 수신자 기기 | 발송 방식 |
|------------|----------|
| iPhone/iPad | iMessage (파란색) |
| Android | SMS (초록색) - iPhone 경유 |

**요구사항**: iPhone의 "문자 메시지 전달" 기능 활성화 필요 (설정 > 메시지 > 문자 메시지 전달)

## Quick Start

### 단일 발송

```bash
.claude/skills/sms-send/scripts/send.sh "010-1234-5678" "메시지 내용"
```

### 대량 발송 (CSV)

```bash
.claude/skills/sms-send/scripts/send_bulk.sh recipients.csv "메시지 내용"
```

CSV 형식:
```csv
이름,전화번호
홍길동,010-1234-5678
김철수,010-9876-5432
```

## AppleScript 직접 사용

### 단일 발송

```applescript
tell application "Messages"
    send "메시지 내용" to buddy "+821012345678"
end tell
```

### 다중 발송

```applescript
set messageText to "메시지 내용"
set phoneNumbers to {"+821012345678", "+821098765432"}

repeat with phoneNum in phoneNumbers
    tell application "Messages"
        send messageText to buddy phoneNum
    end tell
    delay 0.5
end repeat
```

## 전화번호 형식

| 입력 | 변환 결과 |
|------|----------|
| 010-1234-5678 | +821012345678 |
| 01012345678 | +821012345678 |
| +821012345678 | +821012345678 |

## 주의사항

1. **개별 발송**: 각 수신자에게 별도 대화로 전송 (단체 문자 아님)
2. **발송 간격**: 대량 발송 시 0.5초 delay 권장
3. **확인 필수**: 발송 전 Messages 앱에서 수동 확인 권장
4. **개인정보**: 전화번호 포함 파일은 `.gitignore`에 추가

## Troubleshooting

### "buddy를 찾을 수 없음" 에러
- iPhone 문자 메시지 전달 기능 확인
- 전화번호 형식 확인 (+82 국가코드)

### SMS가 안 보내지는 경우
- iPhone과 Mac이 동일 Apple ID인지 확인
- iPhone 설정 > 메시지 > 문자 메시지 전달 > Mac 토글 ON
