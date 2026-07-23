#!/bin/bash

# 가장 최근 수정한 draft 포스트에 현재 date를 입력하는 스크립트

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../../.." && pwd)"
DRAFT_MAIN_DIR="$ROOT_DIR/_drafts"

# 현재 날짜
POST_DATE="$(date '+%Y-%m-%d')"
POST_DATE_TIME="$(date '+%Y-%m-%d %H:%M:%S %:z')"

# _drafts 디렉터리 존재 확인
if [ ! -d "$DRAFT_MAIN_DIR" ]; then
    echo "❌ _drafts 디렉터리를 찾을 수 없습니다."
    echo "   $DRAFT_MAIN_DIR"
    exit 1
fi

# 가장 최근 수정된 md draft 찾기
POST_FILE="$(
    find "$DRAFT_MAIN_DIR" -type f -name "*.md" -printf "%T@ %p\n" \
    | sort -nr \
    | head -n 1 \
    | cut -d' ' -f2-
)"

if [ -z "$POST_FILE" ]; then
    echo "❌ _drafts 디렉터리에서 md 파일을 찾을 수 없습니다."
    exit 1
fi

echo
echo "===== 날짜 입력 대상 파일 ====="
echo "$POST_FILE"
echo

read -p "이 파일에 현재 날짜를 입력하시겠습니까? (Y/n): " CONFIRM

# 앞뒤 공백 제거
CONFIRM="${CONFIRM#"${CONFIRM%%[![:space:]]*}"}"
CONFIRM="${CONFIRM%"${CONFIRM##*[![:space:]]}"}"
CONFIRM="${CONFIRM,,}"

# 엔터만 누르면 y로 처리
if [ -z "$CONFIRM" ]; then
    CONFIRM="y"
fi

if [ "$CONFIRM" != "y" ]; then
    echo "❌ 날짜 입력을 취소했습니다."
    exit 0
fi

# 파일명 변경
OLD_NAME="$(basename "$POST_FILE")"
NEW_NAME="$(echo "$OLD_NAME" | sed -E "s/^[0-9]{4}-[0-9]{2}-[0-9]{2}/${POST_DATE}/")"

NEW_POST_FILE="$(dirname "$POST_FILE")/$NEW_NAME"

# 파일명 변경 (날짜가 달라질 경우만)
if [ "$POST_FILE" != "$NEW_POST_FILE" ]; then
    mv "$POST_FILE" "$NEW_POST_FILE"
    POST_FILE="$NEW_POST_FILE"

    echo "✅ 파일명 변경"
    echo "   $OLD_NAME"
    echo "   → $NEW_NAME"
    echo
fi

# Front Matter 내부의 date만 수정
sed -i.bak "/^---$/,/^---$/ s|^date:.*|date: ${POST_DATE_TIME}|" "$POST_FILE"

rm "${POST_FILE}.bak"

echo
echo "✅ date 입력 완료"
echo "   $POST_FILE"
echo "   date: $POST_DATE_TIME"