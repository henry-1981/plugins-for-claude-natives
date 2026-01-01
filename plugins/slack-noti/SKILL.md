---
name: slack-noti
description: Slack 채널에 알림 메시지 발송. "슬랙 알림", "slack noti", "작업 완료 알림" 요청에 사용. 큰 작업 완료 시 자동 호출.
---

# Slack Noti

Slack API를 통해 `#noti-cc` 채널에 알림 메시지를 발송한다.

## Quick Start

```bash
.claude/skills/slack-noti/scripts/send.sh "메시지 내용"
```

다른 채널로 발송:
```bash
.claude/skills/slack-noti/scripts/send.sh "메시지 내용" "other-channel"
```

## 환경변수

| 변수 | 설명 |
|------|------|
| `SLACK_BOT_TOKEN` | Slack Bot OAuth Token (xoxb-...) |

## 메시지 형식

작업 완료 알림 시 다음 형식 권장:

```
[작업 완료] {작업 요약}
- 수행 내용: {상세 내용}
- 결과: {결과물 또는 위치}
```

예시:
```bash
.claude/skills/slack-noti/scripts/send.sh "[작업 완료] OpenSurvey 프로젝트 문서 정리
- 수행 내용: context.md 업데이트, roadmap 작성
- 결과: projects/opensurvey/ 폴더에 반영"
```

## 자동 알림 트리거

Claude가 다음 작업 완료 시 자동으로 slack-noti 호출:
- PR 생성 완료
- 대규모 코드 수정 (5개 이상 파일)
- 문서 일괄 업데이트
- 분석 리포트 생성
- 장시간 소요 작업 완료

## 주의사항

1. **채널 확인**: 기본 채널은 `#noti-cc`
2. **멘션 주의**: @channel, @here 사용 시 사전 동의 필요
3. **빈도 조절**: 동일 작업에 대해 중복 알림 금지
