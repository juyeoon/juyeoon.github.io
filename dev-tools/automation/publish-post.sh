#!/bin/bash
set -e

# 현재 스크립트 위치 기준으로 프로젝트 루트 계산
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
cd "$ROOT_DIR"

SOURCE_REF="origin/draft"
TARGET_BRANCH="main"
POST_ROOT="_posts"
IMG_ROOT="assets/img/posts_img"
MAX_POST_LIST=5

DRAFT_BRANCH="draft"

echo "━━━━━━━━━━━━━━━━━━━━"
echo " Publish Post"
echo "━━━━━━━━━━━━━━━━━━━━"
echo

# 작업 중인 변경사항 확인
if [ -n "$(git status --porcelain)" ]; then
  echo "❌ 작업 중인 변경사항이 있습니다."
  echo "   commit 또는 stash 후 다시 실행하세요."
  exit 1
fi

# 현재 브랜치 확인
CURRENT_BRANCH="$(git branch --show-current)"

if [ "$CURRENT_BRANCH" != "draft" ]; then
  echo "❌ publish-post.sh는 draft 브랜치에서 실행하는 것을 권장합니다."
  echo "   현재 브랜치: $CURRENT_BRANCH"
  exit 1
fi

# 최신 원격 정보 가져오기
git fetch origin

# 최근 수정한 _posts 하위 md 파일 목록
mapfile -t POST_LIST < <(
  find "$POST_ROOT" -type f -name "*.md" -printf "%T@ %p\n" \
    | sort -nr \
    | head -n "$MAX_POST_LIST" \
    | cut -d' ' -f2-
)

if [ "${#POST_LIST[@]}" -eq 0 ]; then
  echo "❌ $POST_ROOT 에서 포스트를 찾을 수 없습니다."
  exit 1
fi

echo "최근 수정한 포스트 ${MAX_POST_LIST}개"
echo

for i in "${!POST_LIST[@]}"; do
  POST_PATH="${POST_LIST[$i]}"
  CATEGORY="$(echo "$POST_PATH" | cut -d'/' -f2)"
  FILE_NAME="$(basename "$POST_PATH")"

  echo "$((i + 1)). [$CATEGORY] $FILE_NAME"
done

echo
read -rp "번호 선택 > " SELECT_NUM

if ! [[ "$SELECT_NUM" =~ ^[0-9]+$ ]]; then
  echo "❌ 숫자를 입력하세요."
  exit 1
fi

INDEX=$((SELECT_NUM - 1))

if [ "$INDEX" -lt 0 ] || [ "$INDEX" -ge "${#POST_LIST[@]}" ]; then
  echo "❌ 올바른 번호를 선택하세요."
  exit 1
fi

POST_PATH="${POST_LIST[$INDEX]}"
CATEGORY="$(echo "$POST_PATH" | cut -d'/' -f2)"
FILE_NAME="$(basename "$POST_PATH")"

# 파일명 앞 10자리를 날짜로 사용
# 예: 2024-02-19-boj-title.md → 2024-02-19
POST_DATE="${FILE_NAME:0:10}"

# 이미지 파일 규칙:
# assets/img/posts_img/날짜-서브디렉터리-순서.png
# 예: assets/img/posts_img/2024-02-19-boj-01.png
IMAGE_PREFIX="${POST_DATE}-${CATEGORY}"

COMMIT_MESSAGE="feat: post ${FILE_NAME}"

# 이미지 파일 자동 탐색
mapfile -t IMAGE_LIST < <(
  find "$IMG_ROOT" -type f -name "${IMAGE_PREFIX}-*.png" 2>/dev/null \
    | sort
)

echo
echo "━━━━━━━━━━━━━━━━━━━━"
echo " Publish Summary"
echo "━━━━━━━━━━━━━━━━━━━━"
echo
echo "Post"
echo "  $POST_PATH"
echo
echo "Image Prefix"
echo "  ${IMAGE_PREFIX}-*.png"
echo
echo "Images"
echo "  ${#IMAGE_LIST[@]} files"

if [ "${#IMAGE_LIST[@]}" -gt 0 ]; then
  for img in "${IMAGE_LIST[@]}"; do
    echo "  - $img"
  done
fi

echo
echo "Commit"
echo "  $COMMIT_MESSAGE"
echo

read -rp "계속하시겠습니까? [Y/n] " CONFIRM
CONFIRM=${CONFIRM:-Y}

if [[ ! "$CONFIRM" =~ ^[Yy]$ ]]; then
  echo "취소되었습니다."
  exit 0
fi

# 선택한 포스트와 이미지는 main으로 전환하기 전에 임시로 기억
TEMP_DIR="$(mktemp -d)"
TEMP_POST="$TEMP_DIR/$FILE_NAME"

mkdir -p "$(dirname "$TEMP_POST")"
cp "$POST_PATH" "$TEMP_POST"

TEMP_IMAGE_DIR="$TEMP_DIR/images"
mkdir -p "$TEMP_IMAGE_DIR"

if [ "${#IMAGE_LIST[@]}" -gt 0 ]; then
  for img in "${IMAGE_LIST[@]}"; do
    cp "$img" "$TEMP_IMAGE_DIR/"
  done
fi

# main으로 전환 후 최신화
git switch "$TARGET_BRANCH"
git pull --ff-only origin "$TARGET_BRANCH"

# 포스트 복사
mkdir -p "$(dirname "$POST_PATH")"
cp "$TEMP_POST" "$POST_PATH"

# 이미지 복사
if [ "${#IMAGE_LIST[@]}" -gt 0 ]; then
  mkdir -p "$IMG_ROOT"

  for img in "${IMAGE_LIST[@]}"; do
    IMG_FILE="$(basename "$img")"
    cp "$TEMP_IMAGE_DIR/$IMG_FILE" "$IMG_ROOT/$IMG_FILE"
  done
fi

# 임시 디렉터리 삭제
rm -rf "$TEMP_DIR"

# 변경사항 확인
if [ -z "$(git status --porcelain)" ]; then
  echo "ℹ️ 반영할 변경사항이 없습니다."
  exit 0
fi

git add "$POST_PATH"

if [ "${#IMAGE_LIST[@]}" -gt 0 ]; then
  for img in "${IMAGE_LIST[@]}"; do
    git add "$IMG_ROOT/$(basename "$img")"
  done
fi

git commit -m "$COMMIT_MESSAGE"
git push origin "$TARGET_BRANCH"

git switch "$DRAFT_BRANCH"

echo
echo "✅ Publish 완료"
echo "현재 브랜치: $(git branch --show-current)"