#!/bin/bash
set -e

SOURCE_REF="origin/draft"
TARGET_BRANCH="main"
POST_ROOT="_posts"
IMG_ROOT="assets/img/posts_img"

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

# 최신 원격 정보 가져오기
git fetch origin

# draft 브랜치의 _posts 하위 md 파일 목록
mapfile -t POST_LIST < <(git ls-tree -r --name-only "$SOURCE_REF" "$POST_ROOT" | grep '\.md$' || true)

if [ "${#POST_LIST[@]}" -eq 0 ]; then
  echo "❌ $SOURCE_REF 의 $POST_ROOT 에서 포스트를 찾을 수 없습니다."
  exit 1
fi

echo "공개 가능한 포스트"
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
FILE_NAME="$(basename "$POST_PATH")"
POST_NAME="${FILE_NAME%.md}"
COMMIT_MESSAGE="feat: post ${FILE_NAME}"

# 이미지 파일 자동 탐색
mapfile -t IMAGE_LIST < <(
  git ls-tree -r --name-only "$SOURCE_REF" "$IMG_ROOT" \
    | grep -E "/${POST_NAME}-[0-9]+\.png$" || true
)

echo
echo "━━━━━━━━━━━━━━━━━━━━"
echo " Publish Summary"
echo "━━━━━━━━━━━━━━━━━━━━"
echo
echo "Post"
echo "  $POST_PATH"
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

# main으로 전환 후 최신화
git switch "$TARGET_BRANCH"
git pull --ff-only origin "$TARGET_BRANCH"

# 선택한 포스트 가져오기
git restore --source="$SOURCE_REF" -- "$POST_PATH"

# 이미지 가져오기
if [ "${#IMAGE_LIST[@]}" -gt 0 ]; then
  for img in "${IMAGE_LIST[@]}"; do
    git restore --source="$SOURCE_REF" -- "$img"
  done
fi

# 변경사항 확인
if [ -z "$(git status --porcelain)" ]; then
  echo "ℹ️ 반영할 변경사항이 없습니다."
  exit 0
fi

git add "$POST_PATH"

if [ "${#IMAGE_LIST[@]}" -gt 0 ]; then
  git add "${IMAGE_LIST[@]}"
fi

git commit -m "$COMMIT_MESSAGE"
git push origin "$TARGET_BRANCH"

echo
echo "✅ Publish 완료"