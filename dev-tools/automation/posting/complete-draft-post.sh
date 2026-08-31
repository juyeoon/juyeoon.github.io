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

# 본문에서 참조하는 이미지 경로 추출 (예: /assets/img/posts_img/xxx.png)
IMAGE_PATHS="$(
  grep -oE 'assets/img/[A-Za-z0-9_./-]+\.(png|jpg|jpeg|gif|svg|webp)' "$DRAFT_FILE" \
    | sort -u
)"

# 두 파일 add
git add "$DRAFT_FILE" "$POST_FILE"

# 참조된 이미지가 실제로 존재하면 함께 add
if [ -n "$IMAGE_PATHS" ]; then
  while IFS= read -r IMG_REL_PATH; do
    IMG_ABS_PATH="$ROOT_DIR/$IMG_REL_PATH"
    if [ -f "$IMG_ABS_PATH" ]; then
      git add "$IMG_ABS_PATH"
      echo "이미지 추가: $IMG_REL_PATH"
    else
      echo "⚠️  본문에서 참조하지만 파일을 찾을 수 없는 이미지: $IMG_REL_PATH"
    fi
  done <<< "$IMAGE_PATHS"
  echo
fi

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