#!/bin/bash
set -e

# 현재 스크립트 위치 기준으로 프로젝트 루트 계산
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../../.." && pwd)"

DRAFT_ROOT="$ROOT_DIR/_drafts"
POST_ROOT="$ROOT_DIR/_posts"

cd "$ROOT_DIR"

echo "━━━━━━━━━━━━━━━━━━━━"
echo " Complete Draft Post"
echo "━━━━━━━━━━━━━━━━━━━━"
echo

# _drafts 존재 확인
if [ ! -d "$DRAFT_ROOT" ]; then
  echo "❌ _drafts 디렉터리가 존재하지 않습니다: $DRAFT_ROOT"
  exit 1
fi

# 가장 최근 수정한 draft md 파일 찾기
DRAFT_FILE="$(
  find "$DRAFT_ROOT" -type f -name "*.md" -printf "%T@ %p\n" \
    | sort -nr \
    | head -n 1 \
    | cut -d' ' -f2-
)"

if [ -z "$DRAFT_FILE" ]; then
  echo "❌ _drafts 디렉터리에서 md 파일을 찾을 수 없습니다."
  exit 1
fi

# _drafts 기준 상대 경로
REL_PATH="${DRAFT_FILE#$DRAFT_ROOT/}"

# _posts 하위 동일 위치
POST_FILE="$POST_ROOT/$REL_PATH"
POST_DIR="$(dirname "$POST_FILE")"

echo "최근 수정한 draft:"
echo "$DRAFT_FILE"
echo
echo "복사 대상:"
echo "$POST_FILE"
echo

read -p "이 파일을 _posts로 복사하고 커밋하시겠습니까? (Y/n): " CONFIRM
CONFIRM="${CONFIRM:-Y}"

if [[ ! "$CONFIRM" =~ ^[Yy]$ ]]; then
  echo "취소했습니다."
  exit 0
fi

# 대상 디렉터리 생성
mkdir -p "$POST_DIR"

# 파일 복사
cp "$DRAFT_FILE" "$POST_FILE"

FILE_NAME="$(basename "$DRAFT_FILE")"
COMMIT_MSG="wip: ${FILE_NAME} 작성 완료"

# 두 파일 add
git add "$DRAFT_FILE" "$POST_FILE"

# 커밋
git commit -m "$COMMIT_MSG"

echo
echo "✅ 커밋 완료"
echo "커밋 메시지: $COMMIT_MSG"
echo

echo "━━━━━━━━━━━━━━━━━━━━"
echo " Git Status"
echo "━━━━━━━━━━━━━━━━━━━━"
git status