#!/bin/bash

# Chirpy 7.5.0 버전 구조 기준
# 변수 파일을 읽어 _drafts 디렉터리에 초안 포스트를 생성하는 버전

# 현재 스크립트가 위치한 디렉터리 절대 경로
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
# 프로젝트 루트(스크립트 기준 상위 2단계)
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
# 초안 디렉터리
DRAFT_MAIN_DIR="$ROOT_DIR/_drafts"
# 템플릿 디렉터리
TEMPLATE_DIR="$(cd "$SCRIPT_DIR/../templates" && pwd)"

# 포스팅 날짜
POST_DATE="$(date '+%Y-%m-%d')"
POST_DATE_TIME=$(date "+%Y-%m-%d %H:%M:%S %:z")

# 커스텀 변수 =============
TEMPLATE_FILE_NAME="pgsql-template.md"
VAR_INFO_FILE_NAME="pgsql-template-var.txt"
POST_SUB_DIR="pgsql"
# ================

# 파일 경로 변수
DRAFTING_DIR="$DRAFT_MAIN_DIR/$POST_SUB_DIR"  # 결과 초안 파일 저장 경로
POSTING_TEMPLATE="$TEMPLATE_DIR/$TEMPLATE_FILE_NAME"
VAR_INFO_FILE="$SCRIPT_DIR/$VAR_INFO_FILE_NAME"

# 변수 파일 존재 여부 확인
if [ ! -f "$VAR_INFO_FILE" ]; then
  echo "❌ 변수 파일이 존재하지 않습니다: $VAR_INFO_FILE"
  exit 1
fi

# 템플릿 파일 존재 및 읽기 확인
if [ ! -f "$POSTING_TEMPLATE" ]; then
  echo "❌ 템플릿 파일이 존재하지 않습니다: $POSTING_TEMPLATE"
  exit 1
fi

if [ ! -r "$POSTING_TEMPLATE" ]; then
  echo "❌ 템플릿 파일을 읽을 수 없습니다: $POSTING_TEMPLATE"
  exit 1
fi

# 변수 순서대로 읽기
declare -A vars

current_key=""

while IFS= read -r line || [ -n "$line" ]; do
    # CR 제거
    line="${line//$'\r'/}"

    # 앞뒤 공백 제거
    line="${line#"${line%%[![:space:]]*}"}"
    line="${line%"${line##*[![:space:]]}"}"

    # 빈 줄 건너뛰기
    [ -z "$line" ] && continue

    if [[ "$line" == *: ]]; then
        current_key="${line%:}"
    else
        vars["$current_key"]="$line"
        current_key=""
    fi
done < "$VAR_INFO_FILE"

PROBLEM_TITLE="${vars[PROBLEM_TITLE]}"
PROBLEM_ID="${vars[PROBLEM_ID]}"
LANGUAGE="${vars[LANGUAGE]}"
LEVEL="${vars[LEVEL]}"

LANGUAGE="${LANGUAGE,,}"
FILENAME="${POST_DATE}-${POST_SUB_DIR}-${PROBLEM_ID}-${LANGUAGE}.md"

# 템플릿 치환 및 초안 생성
mkdir -p "$DRAFTING_DIR"

sed \
    -e "s|{{PROBLEM_TITLE}}|${PROBLEM_TITLE}|g" \
    -e "s|{{PROBLEM_ID}}|${PROBLEM_ID}|g" \
    -e "s|{{LANGUAGE}}|${LANGUAGE}|g" \
    -e "s|{{LEVEL}}|${LEVEL}|g" \
    -e "s|{{POST_DATE_TIME}}|${POST_DATE_TIME}|g" \
    "$POSTING_TEMPLATE" > "$DRAFTING_DIR/$FILENAME"

echo "✅ 블로그 초안 생성 완료: $DRAFTING_DIR/$FILENAME"

# VS Code로 자동 열기
code "$DRAFTING_DIR/$FILENAME"