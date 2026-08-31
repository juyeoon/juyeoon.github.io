# Dev Tools

블로그 포스팅 작성 및 운영을 위한 자동화 스크립트 모음입니다.

> 이 디렉터리는 `draft` 브랜치에서만 사용합니다.

---

# 디렉터리 구조

```text
dev-tools/
├── automation/
│   ├── posting/      # 초안 작성 ~ _posts 이동
│   ├── publishing/   # 브랜치 간 배포 / 동기화
│   └── server/       # 로컬 Jekyll 서버 실행
└── templates/         # 포스트 템플릿
```

---

# 실행

모든 스크립트는 저장소 루트에서 아래 형식으로 실행합니다.

```bash
bash dev-tools/automation/<posting|publishing>/<스크립트>.sh
```

`.bat` 스크립트는 `dev-tools/automation/server/` 안의 파일을 더블클릭하거나 탐색기에서 직접 실행합니다.

---

# Scripts

## automation/posting

| 스크립트                                   | 설명                                                                          |
| ------------------------------------------ | ----------------------------------------------------------------------------- |
| `create-general-posting.sh`                | 일반 포스트 템플릿으로 `_drafts`에 초안 생성                                 |
| `create-pgsql-post-with-interaction.sh`    | `pgsql-template.md` 템플릿을 복사하고 변수를 입력받아 `_drafts`에 포스트 생성 |
| `create-solvesql-post-with-interaction.sh` | SolveSQL 포스트 정보를 입력받아 `_drafts`에 초안 생성                        |
| `set-post-date.sh`                         | 가장 최근 수정한 `_drafts` 포스트의 `date`와 파일명의 날짜를 현재 시각으로 변경 |
| `wip-commit-draft.sh`                      | 지정한(또는 가장 최근 수정한) `_drafts` 포스트와 본문에서 참조하는 이미지를 함께 wip 커밋 |
| `complete-draft-post.sh`                   | 가장 최근 수정한 `_drafts` 포스트를 `_posts`로 복사하고 두 파일을 커밋       |

## automation/publishing

| 스크립트         | 설명                                                                                                |
| ---------------- | --------------------------------------------------------------------------------------------------- |
| `publish-post.sh` | `draft` 브랜치의 `_posts`에서 공개할 포스트를 선택하여 `main` 브랜치로 복사하고 커밋 및 Push를 수행 (무관한 변경사항은 실행 전 `git stash`, 완료 후 `git stash pop` 필요) |
| `sync-main.sh`    | `main` 브랜치의 공통 변경사항을 `draft` 브랜치로 동기화 (`git merge main` 대신 사용)                |

## automation/server

| 스크립트                            | 설명                                 |
| ------------------------------------ | ------------------------------------ |
| `run-local-jekyll-for-posting.bat`   | 로컬 Jekyll 서버를 실행              |
| `draft-run-local-jekyll.bat`         | `--drafts` 옵션으로 로컬 Jekyll 서버를 실행 |
| `build-and-run-local-jekyll.bat`     | 로컬에서 빌드 후 Jekyll 서버를 실행   |

---

# create-general-posting.sh

### 기능

- `general-template.md` 템플릿 복사
- 작성 날짜 입력 여부 선택
- `_drafts`에 일반 포스트 생성
- 생성된 포스트를 VS Code로 자동 열기

---

# create-pgsql-post-with-interaction.sh

### 기능

- `pgsql-template.md` 템플릿 복사
- 문제 정보(제목, 번호, 언어, 난이도) 입력
- Front Matter 변수 치환
- `_drafts/pgsql`에 포스트 생성
- 생성된 포스트를 VS Code로 자동 열기

---

# create-solvesql-post-with-interaction.sh

### 기능

- `solvesql-template.md` 템플릿 복사
- 문제 정보(제목, 링크 변수, 언어, 난이도) 입력
- Front Matter 변수 치환
- `_drafts/solvesql`에 포스트 생성
- 생성된 포스트를 VS Code로 자동 열기

---

# set-post-date.sh

### 기능

- 가장 최근 수정한 `_drafts` 포스트를 탐색
- 파일명 앞 8자리 날짜를 현재 날짜로 변경
- Front Matter의 `date` 값을 현재 날짜/시각으로 변경

---

# wip-commit-draft.sh

### 기능

- 인자로 파일 경로(또는 파일명 일부)를 넘기면 해당 `_drafts` 포스트를 탐색, 없으면 가장 최근 수정한 `_drafts` 포스트를 사용
- 파일명이 여러 개 검색되면 목록에서 선택
- 대상 포스트 본문에서 `/assets/img/posts_img/` 경로로 참조하는 이미지를 자동으로 찾아 함께 커밋 (참조하지만 실제 파일이 없는 이미지는 경고만 출력)
- 커밋만 수행하고 Push는 하지 않음

### 사용법

```bash
bash dev-tools/automation/posting/wip-commit-draft.sh [파일 경로 또는 파일명 일부]
```

### 커밋 메시지

```text
wip: {파일명.md} 작성 중
```

---

# complete-draft-post.sh

### 기능

- 가장 최근 수정한 `_drafts` 포스트를 탐색
- `_posts` 하위 동일 경로로 복사
- 두 파일을 `git add` 하고 커밋

### 커밋 메시지

```text
wip: {파일명.md} 작성 완료
```

---

# publish-post.sh

### 기능

- `draft` 브랜치인지, 작업 중인 변경사항이 없는지 확인
- 최근 수정한 `_posts` 포스트 최대 5개 중 선택
- 파일명·카테고리 규칙으로 포스트에 대응하는 이미지 자동 탐색
- `main` 브랜치로 전환 후 선택한 포스트와 이미지를 복사, 커밋 및 Push
- 완료 후 다시 `draft` 브랜치로 복귀

### 커밋 메시지

```text
feat: post <파일명.md>
```

### 주의사항

- 스크립트가 작업 중인 변경사항이 없는지(`git status --porcelain` 비어있는지) 먼저 확인하며, 남아있으면 바로 실패합니다.
- 발행과 무관한 변경사항(다른 초안 작업 중인 파일 등)이 있다면 **실행 전에 직접 `git stash -u`로 치워두고, 완료 후 `git stash pop`으로 복원**하세요.
- 스크립트 자체는 자동으로 stash/pop을 하지 않습니다. 스크립트 중간(브랜치 전환, pull, commit, push)에 실패하면 그대로 종료되므로, stash를 걸어둔 채 실행했다면 실패 시 `draft` 브랜치로 돌아온 뒤 `git stash pop`으로 직접 복원해야 합니다.

---

# sync-main.sh

### 기능

- 작업 중인 변경사항이 없는지 확인 후 `draft` 브랜치로 전환
- `origin/main` 기준으로 공통 파일·디렉터리를 `draft`에 반영
- 변경사항이 있으면 확인 후 커밋 및 Push

### 동기화 대상

- `_config.yml`
- `_layouts`
- `_includes`
- `_sass`
- `_tabs`
- `.github/workflows`
- `assets` (단, `assets/img/posts_img` 제외)

### 동기화 제외

- `_drafts`
- `dev-tools`
- `assets/img/posts_img`

---

# run-local-jekyll-for-posting.bat

### 기능

- 로컬 Jekyll 서버를 `--livereload` 옵션으로 실행 (초안 미포함)
- 서버 기동 대기 후 브라우저에서 `localhost:4000` 자동으로 열기

---

# draft-run-local-jekyll.bat

### 기능

- 로컬 Jekyll 서버를 `--drafts --livereload` 옵션으로 실행 (초안 포함)
- 서버 기동 대기 후 브라우저에서 `localhost:4000` 자동으로 열기

---

# build-and-run-local-jekyll.bat

### 기능

- `npm run build`로 테마 에셋 빌드
- `jekyll clean`으로 기존 빌드 결과물 정리
- 로컬 Jekyll 서버를 `--livereload` 옵션으로 실행
- 서버 기동 대기 후 브라우저에서 `localhost:4000` 자동으로 열기

---

# Templates

| 템플릿                 | 설명                                         |
| ---------------------- | -------------------------------------------- |
| `general-template.md`  | 일반 포스트 작성용 템플릿입니다.             |
| `pgsql-template.md`    | 프로그래머스 SQL 포스트 작성용 템플릿입니다. |
| `solvesql-template.md` | SolveSQL SQL 포스트 작성용 템플릿입니다.     |
