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

# Scripts

## automation/posting

| 스크립트                                   | 설명                                                                          |
| ------------------------------------------ | ----------------------------------------------------------------------------- |
| `create-general-posting.sh`                | 일반 포스트 템플릿으로 `_drafts`에 초안 생성                                 |
| `create-pgsql-post-with-interaction.sh`    | `pgsql-template.md` 템플릿을 복사하고 변수를 입력받아 `_drafts`에 포스트 생성 |
| `create-solvesql-post-with-interaction.sh` | SolveSQL 포스트 정보를 입력받아 `_drafts`에 초안 생성                        |
| `set-post-date.sh`                         | 가장 최근 수정한 `_drafts` 포스트의 `date`와 파일명의 날짜를 현재 시각으로 변경 |
| `complete-draft-post.sh`                   | 가장 최근 수정한 `_drafts` 포스트를 `_posts`로 복사하고 두 파일을 커밋       |

## automation/publishing

| 스크립트         | 설명                                                                                                |
| ---------------- | --------------------------------------------------------------------------------------------------- |
| `publish-post.sh` | `draft` 브랜치의 `_posts`에서 공개할 포스트를 선택하여 `main` 브랜치로 복사하고 커밋 및 Push를 수행 |
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

### 실행

```bash
bash dev-tools/automation/posting/create-general-posting.sh
```

---

# create-pgsql-post-with-interaction.sh

### 기능

- `pgsql-template.md` 템플릿 복사
- 문제 정보(제목, 번호, 언어, 난이도) 입력
- Front Matter 변수 치환
- `_drafts/pgsql`에 포스트 생성
- 생성된 포스트를 VS Code로 자동 열기

### 실행

```bash
bash dev-tools/automation/posting/create-pgsql-post-with-interaction.sh
```

---

# create-solvesql-post-with-interaction.sh

### 기능

- `solvesql-template.md` 템플릿 복사
- 문제 정보(제목, 링크 변수, 언어, 난이도) 입력
- Front Matter 변수 치환
- `_drafts/solvesql`에 포스트 생성
- 생성된 포스트를 VS Code로 자동 열기

### 실행

```bash
bash dev-tools/automation/posting/create-solvesql-post-with-interaction.sh
```

---

# set-post-date.sh

### 실행

```bash
bash dev-tools/automation/posting/set-post-date.sh
```

---

# complete-draft-post.sh

### 커밋 메시지

```text
wip: {파일명.md} 작성 완료
```

### 실행

```bash
bash dev-tools/automation/posting/complete-draft-post.sh
```

---

# publish-post.sh

### 커밋 메시지

```text
feat: post <파일명.md>
```

### 실행

```bash
bash dev-tools/automation/publishing/publish-post.sh
```

---

# sync-main.sh

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

### 실행

```bash
bash dev-tools/automation/publishing/sync-main.sh
```

---

# Templates

| 템플릿                 | 설명                                         |
| ---------------------- | -------------------------------------------- |
| `general-template.md`  | 일반 포스트 작성용 템플릿입니다.             |
| `pgsql-template.md`    | 프로그래머스 SQL 포스트 작성용 템플릿입니다. |
| `solvesql-template.md` | SolveSQL SQL 포스트 작성용 템플릿입니다.     |
