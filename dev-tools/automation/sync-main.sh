#!/bin/bash
set -e

SOURCE_REF="origin/main"
TARGET_BRANCH="draft"

echo "━━━━━━━━━━━━━━━━━━━━"
echo " Sync Main Changes"
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

# draft 브랜치로 전환
git switch "$TARGET_BRANCH"

echo
echo "main 브랜치의 공통 변경사항을 draft 브랜치로 가져옵니다."
echo "단, draft 전용 파일과 assets/img/posts_img 는 제외합니다."
echo

COMMON_FILES=(
  "_config.yml"
  "Gemfile"
  "Gemfile.lock"
  "package.json"
  "package-lock.json"
  "eslint.config.js"
  "purgecss.js"
  "rollup.config.js"
  "README.md"
)

COMMON_DIRS=(
  ".github/workflows"
  "_data"
  "_includes"
  "_layouts"
  "_sass"
  "_tabs"
)

ASSET_DIRS=(
  "assets/css"
  "assets/js"
  "assets/lib"
)

# 단일 파일 동기화
for file in "${COMMON_FILES[@]}"; do
  if git cat-file -e "$SOURCE_REF:$file" 2>/dev/null; then
    git restore --source="$SOURCE_REF" -- "$file"
  fi
done

# 공통 디렉터리 동기화
for dir in "${COMMON_DIRS[@]}"; do
  if git cat-file -e "$SOURCE_REF:$dir" 2>/dev/null; then
    git restore --source="$SOURCE_REF" -- "$dir"
  fi
done

# assets 중 posts_img를 제외한 공통 assets만 동기화
for dir in "${ASSET_DIRS[@]}"; do
  if git cat-file -e "$SOURCE_REF:$dir" 2>/dev/null; then
    git restore --source="$SOURCE_REF" -- "$dir"
  fi
done

# 변경사항 확인
if [ -z "$(git status --porcelain)" ]; then
  echo "ℹ️ 동기화할 변경사항이 없습니다."
  exit 0
fi

echo
echo "동기화될 변경사항:"
git status --short
echo

read -rp "이 변경사항을 draft에 커밋하시겠습니까? [Y/n] " CONFIRM
CONFIRM=${CONFIRM:-Y}

if [[ ! "$CONFIRM" =~ ^[Yy]$ ]]; then
  echo "취소되었습니다."
  exit 0
fi

git add .

git commit -m "chore: main 변경사항 동기화"
git push origin "$TARGET_BRANCH"

echo
echo "✅ draft 동기화 완료"