#!/bin/bash
set -e

# 작성 중인 draft 포스트와, 포스트 안에서 참조하는 이미지를 함께 wip 커밋하는 스크립트
# Push는 수행하지 않는다.

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../../.." && pwd)"

DRAFT_ROOT="$ROOT_DIR/_drafts"

cd "$ROOT_DIR"

echo "━━━━━━━━━━━━━━━━━━━━"
echo " WIP Commit Draft"
echo "━━━━━━━━━━━━━━━━━━━━"
echo

# _drafts 존재 확인
if [ ! -d "$DRAFT_ROOT" ]; then
  echo "❌ _drafts 디렉터리가 존재하지 않습니다: $DRAFT_ROOT"
  exit 1
fi

TARGET_INPUT="$1"

if [ -n "$TARGET_INPUT" ]; then
  if [ -f "$TARGET_INPUT" ]; then
    DRAFT_FILE="$(cd "$(dirname "$TARGET_INPUT")" && pwd)/$(basename "$TARGET_INPUT")"
  elif [ -f "$DRAFT_ROOT/$TARGET_INPUT" ]; then
    DRAFT_FILE="$DRAFT_ROOT/$TARGET_INPUT"
  else
    # 파일명(일부)로 _drafts 하위를 검색
    mapfile -t MATCHES < <(
      find "$DRAFT_ROOT" -type f -iname "*${TARGET_INPUT}*.md" 2>/dev/null | sort
    )

    if [ "${#MATCHES[@]}" -eq 0 ]; then
      echo "❌ '${TARGET_INPUT}'와(과) 일치하는 draft 파일을 찾을 수 없습니다."
      exit 1
    elif [ "${#MATCHES[@]}" -eq 1 ]; then
      DRAFT_FILE="${MATCHES[0]}"
    else
      echo "여러 개의 draft 파일이 검색되었습니다."
      echo
      for i in "${!MATCHES[@]}"; do
        echo "$((i + 1)). ${MATCHES[$i]#$DRAFT_ROOT/}"
      done
      echo
      read -rp "번호 선택 > " SELECT_NUM

      if ! [[ "$SELECT_NUM" =~ ^[0-9]+$ ]]; then
        echo "❌ 숫자를 입력하세요."
        exit 1
      fi

      INDEX=$((SELECT_NUM - 1))

      if [ "$INDEX" -lt 0 ] || [ "$INDEX" -ge "${#MATCHES[@]}" ]; then
        echo "❌ 올바른 번호를 선택하세요."
        exit 1
      fi

      DRAFT_FILE="${MATCHES[$INDEX]}"
    fi
  fi
else
  # 인자가 없으면 가장 최근 수정한 draft md 파일 사용
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
fi

if [ ! -f "$DRAFT_FILE" ]; then
  echo "❌ 파일을 찾을 수 없습니다: $DRAFT_FILE"
  exit 1
fi

case "$DRAFT_FILE" in
  "$DRAFT_ROOT"/*) ;;
  *)
    echo "❌ _drafts 디렉터리 안의 파일만 지정할 수 있습니다."
    exit 1
    ;;
esac

FILE_NAME="$(basename "$DRAFT_FILE")"

# 포스트 본문에서 참조하는 posts_img 이미지 경로 추출
mapfile -t IMAGE_REFS < <(
  grep -oE '/assets/img/posts_img/[^)"'"'"'[:space:]]+' "$DRAFT_FILE" | sort -u
)

FOUND_IMAGES=()
MISSING_IMAGES=()

for ref in "${IMAGE_REFS[@]}"; do
  IMG_PATH="$ROOT_DIR${ref}"
  if [ -f "$IMG_PATH" ]; then
    FOUND_IMAGES+=("$IMG_PATH")
  else
    MISSING_IMAGES+=("$ref")
  fi
done

COMMIT_MESSAGE="wip: ${FILE_NAME} 작성 중"

echo "대상 draft:"
echo "  $DRAFT_FILE"
echo
echo "참조 이미지 (${#FOUND_IMAGES[@]}개)"

if [ "${#FOUND_IMAGES[@]}" -gt 0 ]; then
  for img in "${FOUND_IMAGES[@]}"; do
    echo "  - $img"
  done
fi

if [ "${#MISSING_IMAGES[@]}" -gt 0 ]; then
  echo
  echo "⚠️  본문에서 참조하지만 실제 파일이 없는 이미지"
  for ref in "${MISSING_IMAGES[@]}"; do
    echo "  - $ref"
  done
fi

echo
echo "커밋 메시지"
echo "  $COMMIT_MESSAGE"
echo

read -rp "이 파일과 이미지를 커밋하시겠습니까? [Y/n] " CONFIRM
CONFIRM="${CONFIRM:-Y}"

if [[ ! "$CONFIRM" =~ ^[Yy]$ ]]; then
  echo "취소했습니다."
  exit 0
fi

git add "$DRAFT_FILE"

if [ "${#FOUND_IMAGES[@]}" -gt 0 ]; then
  for img in "${FOUND_IMAGES[@]}"; do
    git add "$img"
  done
fi

if [ -z "$(git status --porcelain -- "$DRAFT_FILE" "${FOUND_IMAGES[@]}")" ]; then
  echo "ℹ️ 커밋할 변경사항이 없습니다."
  exit 0
fi

git commit -m "$COMMIT_MESSAGE"

echo
echo "✅ 커밋 완료"
echo "커밋 메시지: $COMMIT_MESSAGE"
echo

echo "━━━━━━━━━━━━━━━━━━━━"
echo " Committed Files"
echo "━━━━━━━━━━━━━━━━━━━━"
git show --stat --oneline HEAD
