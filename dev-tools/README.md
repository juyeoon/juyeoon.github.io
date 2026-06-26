# Dev Tools

블로그 포스팅 작성 및 운영을 위한 자동화 스크립트 모음입니다.

> 이 디렉터리는 `draft` 브랜치에서만 사용합니다.

---

# Scripts

| 스크립트                       | 설명                                                                                                |
| ------------------------------ | --------------------------------------------------------------------------------------------------- |
| `create-pgsql-post-*.sh`       | `pgsql-template.md` 템플릿을 복사하고 변수를 치환하여 `_drafts`에 포스트 생성                       |
| `set-post-date.sh`             | 가장 최근 수정한 `_drafts` 포스트의 `date`와 파일명의 날짜를 현재 시각으로 변경                     |
| `publish-post.sh`              | `draft` 브랜치의 `_posts`에서 공개할 포스트를 선택하여 `main` 브랜치로 복사하고 커밋 및 Push를 수행 |
| `sync-main.sh`                 | `main` 브랜치의 공통 변경사항을 `draft` 브랜치로 동기화 (`git merge main` 대신 사용)                |
| `run-local-jekyll-*`           | 로컬 Jekyll 서버를 실행                                                                             |
| `build-and-run-local-jekyll.*` | 로컬에서 빌드 후 Jekyll 서버를 실행                                                                 |

---

# publish-post.sh

### 커밋 메시지

```text
feat: post <파일명.md>
```

### 실행

```bash
bash dev-tools/automation/publish-post.sh
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
bash dev-tools/automation/sync-main.sh
```

---

# set-post-date.sh

### 실행

```bash
bash dev-tools/automation/set-post-date.sh
```

---

# Templates

| 템플릿              | 설명                                         |
| ------------------- | -------------------------------------------- |
| `pgsql-template.md` | 프로그래머스 SQL 포스트 작성용 템플릿입니다. |