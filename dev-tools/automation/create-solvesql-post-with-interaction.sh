#!/bin/bash

# Chirpy 7.5.0 버전 구조 기준
# draft 브랜치에서 _drafts 디렉터리에 초안 포스트를 생성하는 스크립트

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
DRAFT_MAIN_DIR="$ROOT_DIR/_drafts"
TEMPLATE_DIR="$(cd "$SCRIPT_DIR/../templates" && pwd)"

POST_DATE="$(date '+%Y-%m-%d')"
POST_DATE_TIME="$(date '+%Y-%m-%d %H:%M:%S %:z')"

TEMPLATE_FILE_NAME="solvesql-template.md"
POST_SUB_DIR="solvesql"

DRAFTING_DIR="$DRAFT_MAIN_DIR/$POST_SUB_DIR"
POSTING_TEMPLATE="$TEMPLATE_DIR/$TEMPLATE_FILE_NAME"

if [ ! -f "$POSTING_TEMPLATE" ]; then
    echo "❌ 템플릿 파일이 존재하지 않습니다: $POSTING_TEMPLATE"
    exit 1
fi

if [ ! -r "$POSTING_TEMPLATE" ]; then
    echo "❌ 템플릿 파일을 읽을 수 없습니다: $POSTING_TEMPLATE"
    exit 1
fi

echo
echo "===== 포스팅 정보 입력 ====="

read -p "문제 제목: " PROBLEM_TITLE
read -p "문제 링크 변수: " PROBLEM_TITLE_DASH
read -p "언어: " LANGUAGE
read -p "난이도: " LEVEL

echo
read -p "현재 날짜를 바로 입력할까요? (Y/n): " USE_DATE
USE_DATE="${USE_DATE:-y}"

for var in PROBLEM_TITLE PROBLEM_ID LANGUAGE LEVEL USE_DATE; do
    value="${!var}"
    value="${value#"${value%%[![:space:]]*}"}"
    value="${value%"${value##*[![:space:]]}"}"
    printf -v "$var" "%s" "$value"
done

# 제목에는 입력한 그대로 사용
TITLE_LANGUAGE="$LANGUAGE"

# 파일명에는 소문자 사용
LANGUAGE="${LANGUAGE,,}"
USE_DATE="${USE_DATE,,}"

if [ "$USE_DATE" = "y" ]; then
    FINAL_POST_DATE_TIME="$POST_DATE_TIME"
else
    FINAL_POST_DATE_TIME=""
fi

FILENAME="${POST_DATE}-${POST_SUB_DIR}-${PROBLEM_TITLE_DASH}-${LANGUAGE}.md"

mkdir -p "$DRAFTING_DIR"

sed \
    -e "s|{{PROBLEM_TITLE}}|${PROBLEM_TITLE}|g" \
    -e "s|{{TITLE_LANGUAGE}}|${TITLE_LANGUAGE}|g" \
    -e "s|{{PROBLEM_TITLE_DASH}}|${PROBLEM_TITLE_DASH}|g" \
    -e "s|{{LANGUAGE}}|${LANGUAGE}|g" \
    -e "s|{{LEVEL}}|${LEVEL}|g" \
    -e "s|{{POST_DATE_TIME}}|${FINAL_POST_DATE_TIME}|g" \
    "$POSTING_TEMPLATE" > "$DRAFTING_DIR/$FILENAME"

echo
echo "✅ 블로그 초안 생성 완료"
echo "   $DRAFTING_DIR/$FILENAME"

code "$DRAFTING_DIR/$FILENAME"