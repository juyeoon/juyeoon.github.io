# docs/git-workflow.md

# Git Workflow

## 왜 이 Workflow를 사용하는가?

이 저장소는 Git을 단순한 버전 관리 도구가 아니라 **포스팅 작업 공간**으로 사용한다.

이 Workflow를 선택한 이유는 다음과 같다.

- 작성 중인 포스팅을 GitHub에 백업하기 위해
- 여러 PC에서 이어서 작업하기 위해
- 작성 과정도 Git으로 관리하기 위해
- GitHub Contribution을 꾸준히 유지하기 위해
- 포스팅 작성과 배포를 명확하게 분리하기 위해
- `main` 브랜치를 항상 배포 가능한 상태로 유지하기 위해

---

# 브랜치 역할

## main

배포 브랜치

역할

- GitHub Pages 배포 대상
- 공개된 포스팅 관리
- 블로그 구조 및 설정 관리
- 항상 배포 가능한 상태 유지

---

## draft

작업 브랜치

역할

- 작성 중인 포스팅 관리
- 장기간 수정 작업
- 여러 PC에서 이어서 작업
- 작업 내용 백업

Build와 Deploy는 수행하지 않는다.

---

# main 브랜치 정책

`main` 브랜치에는 작성 중인 포스팅을 두지 않는다.

```text
_posts/
    공개된 포스팅
```

`_drafts`는 `main`에서 관리하지 않는다.

---

# draft 브랜치 정책

작성 중인 포스팅은 모두 `draft` 브랜치에서 관리한다.

```text
_posts/
    공개된 포스팅

_drafts/
    작성 중인 포스팅
```

작성이 완료되면 `_drafts`에서 `_posts`로 이동한다.

---

# GitHub Actions

GitHub Actions는 `main` 브랜치에서만 실행한다.

| 브랜치 | Build | Deploy |
| ------ | :---: | :----: |
| main   |  ✅   |   ✅   |
| draft  |  ❌   |   ❌   |

---

# 작업 흐름

## 1. 작업 시작

```bash
git switch draft
git pull origin draft
```

---

## 2. 포스팅 작성

`draft` 브랜치의 `_drafts`에서 작업한다.

작업 중에는 자유롭게 Commit과 Push를 수행한다.

```text
작성
    │
Commit
    │
 Push
    │
GitHub
    │
다른 PC
    │
 Pull
    │
계속 작업
```

---

## 3. 포스팅 완료

완성된 글은 `_drafts`에서 `_posts`로 이동한다.

이후 `draft` 브랜치에 Commit과 Push를 수행한다.

---

## 4. 포스팅 공개

공개는 `publish-post.sh`를 사용한다.

```bash
bash publish-post.sh
```

`publish-post.sh`는 공개할 포스팅을 `main` 브랜치에 반영하기 위한 스크립트이다.

---

# 기존 포스팅 수정

## main에서 직접 수정하는 경우

다음과 같이 **바로 공개해도 문제가 없는 작업**은 `main`에서 직접 수정한다.

예시

- 오타 수정
- 링크 수정
- 태그 수정
- 카테고리 수정
- 이미지 경로 수정
- 코드 블록 언어 수정

---

## draft에서 수정하는 경우

다음과 같이 **작업 시간이 길거나 중간 상태를 공개하고 싶지 않은 작업**은 `draft`에서 수정한다.

예시

- 내용 추가
- 문서 구조 변경
- 예제 코드 교체
- 이미지 대량 수정
- 며칠에 걸친 수정 작업

완료 후 `publish-post.sh`를 통해 공개한다.

---

# 블로그 구조 변경

다음과 같은 블로그 전체 변경 사항은 `main`에서 관리한다.

예시

- Chirpy 업데이트
- `_config.yml`
- GitHub Actions
- 공통 스크립트
- 레이아웃 수정
- Include 수정
- Assets 구조 변경

구조 변경 후에는 `draft`를 최신 상태로 맞춘다.

```bash
git switch draft
git merge main
git push origin draft
```

---

# draft 최신화

평소에는 `draft`를 최신 상태로 유지할 필요는 없다.

다만 다음과 같은 경우에는 `main`의 변경 사항을 반영한다.

- 블로그 구조 변경
- 설정 변경
- 공통 스크립트 변경
- 이후 `draft`에서 이어서 작업해야 하는 변경 사항이 있는 경우

---

# 운영 원칙

## draft

- 포스팅 작업 공간
- 초안 백업 공간
- 여러 PC 작업 공간
- 자유로운 Commit 허용
- Build / Deploy 없음

---

## main

- 배포 브랜치
- 공개된 포스팅 관리
- 블로그 구조 및 설정 관리
- 항상 배포 가능한 상태 유지
- 의미 있는 Commit History 유지

---

# 전체 Workflow

```text
                 draft
                    │
          작성 / 수정 / 백업
                    │
          Commit & Push
                    │
             (No Build)
                    │
         완성 후 _posts 이동
                    │
                    ▼
          publish-post.sh
                    │
                    ▼
                 main
                    │
             Commit & Push
                    │
                    ▼
       GitHub Actions Build
                    │
                    ▼
        GitHub Pages Deploy
```

---

# 참고

이 저장소는 일반적인 Git Flow를 따르지 않는다.

`draft` 브랜치는 기능 개발 브랜치가 아니라 **포스팅 작업 공간**으로 사용한다.

`main`은 **배포 브랜치**이며, 공개할 포스팅과 블로그 운영에 필요한 변경 사항만 관리한다.

포스팅 공개는 브랜치 병합(Merge)이 아니라 **`publish-post.sh`를 통한 파일 단위 배포**를 기본 원칙으로 한다.
