---
name: youtube-digest
description: YouTube 영상의 transcript를 가져와서 요약, 인사이트, 한글 번역을 생성하고, 3단계 퀴즈(총 9문제)로 학습 이해도를 테스트합니다. 퀴즈 후 Deep Research 옵션으로 웹 심층 조사도 가능. "유튜브 정리", "영상 요약", "transcript 번역" 요청에 사용.
---

# YouTube Digest

YouTube 영상을 분석하여 요약/인사이트/번역 문서를 생성하고, 학습 퀴즈로 이해도를 테스트하는 skill.

## 워크플로우

### 1단계: 영상 메타데이터 수집

```bash
# 메타데이터 추출 (제목, 설명, 채널명 등)
yt-dlp --dump-json --no-download "<URL>"
```

추출 항목:
- `title`: 영상 제목
- `description`: 영상 설명
- `channel`: 채널명
- `upload_date`: 업로드 날짜
- `duration`: 영상 길이
- `tags`: 태그 목록

### 2단계: Transcript 추출

```bash
# 자동 생성 자막 포함하여 추출
yt-dlp --write-auto-sub --sub-lang "en,ko" --skip-download --sub-format "vtt" -o "%(title)s.%(ext)s" "<URL>"

# 또는 JSON 형태로 자막 추출
yt-dlp --write-auto-sub --sub-lang "en,ko" --skip-download --convert-subs json3 -o "%(title)s.%(ext)s" "<URL>"
```

우선순위:
1. 수동 자막 (ko → en)
2. 자동 생성 자막 (ko → en)

### 3단계: 맥락 파악 및 고유명사 수집 (WebSearch)

자막이 불완전할 수 있으므로 웹 검색으로 맥락 파악:

검색 쿼리 예시:
- `"{영상 제목}" {채널명} summary`
- `"{발표자명}" {주제 키워드}`
- `{제품명/기술명} overview`

목적:
- 전문 용어의 정확한 표기 확인
- 고유명사(인명, 제품명, 회사명) 확인
- 영상에서 언급된 개념의 배경 이해

**고유명사 수집**: 웹 검색 결과에서 발견된 정확한 표기를 목록으로 정리
```
예시:
- Cora (이메일 앱) - transcript에서 "Kora"로 오인식 가능
- Every.to (회사명)
- Dan Shipper (발표자)
- Compounding Engineering (개념명)
```

### 4단계: Transcript 교정 (고유명사 대체)

**중요**: 자동 자막은 고유명사를 발음 기반으로 잘못 인식하는 경우가 많음.
웹 검색에서 확인된 정확한 표기로 transcript의 오인식 단어를 대체한다.

교정 대상:
- 제품명: Kora → Cora, Codex → Codex 등
- 인명: 발음이 비슷한 다른 이름으로 잘못 인식된 경우
- 회사명: every → Every.to 등
- 기술 용어: cloud code → Claude Code 등

교정 방법:
1. 웹 검색에서 수집한 고유명사 목록 참조
2. Transcript에서 발음이 유사한 오인식 단어 탐색
3. 정확한 표기로 일괄 대체

```
교정 예시:
| 오인식 (자막) | 정확한 표기 (웹 검색) | 이유 |
|--------------|---------------------|------|
| Kora         | Cora                | 동일 발음 /ˈkɔːrə/ |
| cloud code   | Claude Code         | 동일 발음 |
| every        | Every.to            | 회사명 |
```

### 5단계: 문서 생성

아래 형식으로 마크다운 문서 생성:

```markdown
---
title: {영상 제목}
url: {YouTube URL}
channel: {채널명}
date: {업로드 날짜}
duration: {영상 길이}
processed_at: {처리 일시}
---

# {영상 제목}

## 요약

{3-5문장으로 핵심 내용 요약}

- 주요 포인트 1
- 주요 포인트 2
- 주요 포인트 3

## 인사이트

{영상에서 얻을 수 있는 인사이트와 시사점}

### 핵심 아이디어
- {아이디어 1}
- {아이디어 2}

### 적용 가능한 점
- {실행 가능한 takeaway}

## 전체 스크립트 (한글 번역)

{timestamp가 있으면 포함하여 전체 transcript 한글 번역}

[00:00] ...
[01:30] ...
```

### 6단계: 파일 저장

저장 위치: `research/readings/youtube/`
파일명: `{YYYY-MM-DD}-{sanitized-title}.md`

```bash
# 예시
research/readings/youtube/2024-12-31-how-to-build-ai-agents.md
```

### 7단계: 학습 퀴즈

영상 내용 이해도를 테스트하는 퀴즈를 3단계로 진행한다.

#### 퀴즈 구성

| 단계 | 난이도 | 출제 기준 | 문제 수 |
|------|--------|----------|--------|
| 1단계 | 기본 | 핵심 인사이트, 주요 개념 | 3문제 |
| 2단계 | 중급 | 인사이트 + 세부 내용 연결 | 3문제 |
| 3단계 | 심화 | 세부 내용, 적용/분석 | 3문제 |

#### 퀴즈 진행 방식

각 단계에서 AskUserQuestion을 사용하여 3개 문제를 동시에 출제:

```
AskUserQuestion:
questions:
  - question: "[1단계 - 기본] 질문 1..."
    header: "Q1"
    options:
      - label: "A"
        description: "선택지 A 설명"
      - label: "B"
        description: "선택지 B 설명"
      - label: "C"
        description: "선택지 C 설명"
      - label: "D"
        description: "선택지 D 설명"
    multiSelect: false
  - question: "[1단계 - 기본] 질문 2..."
    header: "Q2"
    ...
  - question: "[1단계 - 기본] 질문 3..."
    header: "Q3"
    ...
```

#### 문제 유형 가이드

**1단계 (기본)** - 인사이트 이해도 확인:
- "이 영상의 핵심 메시지는 무엇인가요?"
- "발표자가 강조한 가장 중요한 원칙은?"
- "영상에서 제시한 주요 문제점은?"

**2단계 (중급)** - 인사이트와 세부 내용 연결:
- "X 개념이 중요한 이유로 발표자가 든 근거는?"
- "A와 B의 차이점으로 설명된 것은?"
- "해당 전략의 장점으로 언급된 것은?"

**3단계 (심화)** - 세부 내용 및 적용:
- "언급된 사례에서 성공 요인으로 분석된 것은?"
- "이 접근법을 적용할 때 주의점으로 언급된 것은?"
- "발표자가 제시한 구체적인 수치/데이터는?"

#### 결과 처리

각 단계 완료 후:
1. 정답/오답 즉시 표시
2. **틀린 문제에 대해 상세 해설 제공**:
   - 정답이 무엇인지
   - 왜 그것이 정답인지 (영상 내용 참조)
   - 관련 타임스탬프 (있을 경우)

3단계 모두 완료 후 최종 점수 요약:
```
## 퀴즈 결과
- 1단계: 3/3 ✅
- 2단계: 2/3 (Q2 오답)
- 3단계: 2/3 (Q1 오답)
- **총점: 7/9 (78%)**
```

### 8단계: 후속 선택

퀴즈 완료 후 사용자에게 다음 단계 선택 제시:

```
AskUserQuestion:
question: "퀴즈를 완료했습니다! 다음으로 무엇을 할까요?"
header: "Next Step"
options:
  - label: "한 번 더 퀴즈"
    description: "다른 문제로 다시 테스트 (틀린 부분 보완)"
  - label: "Deep Research"
    description: "이 주제에 대해 웹에서 심층 조사 수행"
  - label: "종료"
    description: "여기서 마무리"
multiSelect: false
```

#### Deep Research 워크플로우

"Deep Research" 선택 시:

1. **병렬 웹 검색** (WebSearch × 3-5개 쿼리 동시 실행):
   - `"{주제}" 심층 분석`
   - `"{핵심 개념}" 사례 연구`
   - `"{발표자/채널}" 관련 자료`
   - `"{기술/방법론}" best practices`
   - `"{주제}" research paper`

2. **병렬 웹 페이지 수집** (WebFetch):
   - 검색 결과 중 관련성 높은 3-5개 페이지 병렬 fetch

3. **기존 문서 확장**:
   원본 YouTube Digest 파일에 `## Deep Research` 섹션 추가:

```markdown
## Deep Research

> 생성일: {날짜}
> 검색 쿼리: {사용된 쿼리 목록}

### 추가 맥락

{웹 검색으로 발견한 배경 정보, 관련 개념 확장}

### 관련 자료

| 출처 | 요약 | URL |
|------|------|-----|
| {출처1} | {1줄 요약} | {URL} |
| {출처2} | {1줄 요약} | {URL} |

### 심화 인사이트

{영상 내용 + 웹 검색 결과를 종합한 추가 인사이트}

### 실행 가능한 Next Steps

- {구체적인 액션 아이템 1}
- {구체적인 액션 아이템 2}
```

## 사용 예시

```
사용자: 이 유튜브 정리해줘 https://www.youtube.com/watch?v=xxxxx
```

## 참고사항

### 자막 언어 우선순위
1. 한국어 수동 자막
2. 영어 수동 자막
3. 한국어 자동 생성
4. 영어 자동 생성

### 불완전한 자막 처리
- 자동 생성 자막의 고유명사 오인식은 **4단계(Transcript 교정)**에서 일괄 대체
- 웹 검색 결과의 표기를 우선 신뢰 (자막보다 정확도 높음)
- 문맥상 이해 불가능한 부분은 `[불명확]` 표시
- 발음이 동일한 단어 주의: Kora/Cora, cloud/Claude, every/Every.to 등

### yt-dlp 유용한 옵션
- `--list-subs`: 사용 가능한 자막 목록 확인
- `--cookies-from-browser chrome`: 로그인 필요한 영상용
