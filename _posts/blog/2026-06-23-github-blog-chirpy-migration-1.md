---
title: "🔄 Jekyll Chirpy Migration (1) - 6.4.2에서 7.5.0으로 업그레이드"
date: 2026-06-23 15:47:04 +09:00
categories: [blog, jekyll]
tags: [github, blog, chirpy, github-pages]
---

👉 이번 포스팅에서는 Jekyll Chirpy 6.4.2를 7.5.0으로 마이그레이션한 과정을 정리했다. 최신 소스를 기준으로 프로젝트 구조 변경에 대응하고 테마를 안전하게 적용한 과정을 기록한다.

<br/>

> 📚 **Jekyll Chirpy Migration**
>
> - **(1) 6.4.2에서 7.5.0으로 업그레이드** ← 현재 글

<!-- > - (2) 기존 커스텀 기능 복원 -->

---

## 📌 업데이트를 결심한 이유

새로운 PC에서 GitHub 블로그 개발 환경을 다시 구성하던 중
`bundle install` 단계에서 Gem 설치 오류가 발생했다.

![image]({{ site.url }}{{ site.baseurl }}/assets/img/posts_img/2026-06-23-blog-01.png)

오류의 원인은 최신 Ruby 환경과 오래된 `wdm` Gem 사이의 호환성 문제였다.

> **💡 Gem이란?**
>
> Ruby에서 사용하는 라이브러리(패키지)를 의미한다.
> Java의 Maven/Gradle 의존성이나 Node.js의 npm Package와 비슷한 개념으로,
> `bundle install` 명령을 실행하면 `Gemfile`에 정의된 Gem들이 자동으로 설치된다.

> **💡 wdm이란?**
>
> `wdm(Windows Directory Monitor)`은 Windows에서 파일이나 디렉터리의 변경 사항을 감지하는 Gem이다.
> Jekyll 개발 서버(`jekyll serve`)가 파일 수정 사항을 빠르게 인식하여 자동으로 다시 빌드할 수 있도록 도와준다.
>
> 기존 테마에서는 `wdm v0.1.1`을 사용하고 있었는데, 최신 Ruby 환경에서는 해당 버전이 정상적으로 빌드되지 않아 호환성 문제가 발생했다.

새로운 PC에 최신 Ruby를 설치하면서 이 버전이 정상적으로 빌드되지 않아 `bundle install`이 실패한 것이다.

원인을 확인하기 위해 [Chirpy 공식 Repository](https://github.com/cotes2020/jekyll-theme-chirpy)를 살펴보니, `wdm` 버전뿐만 아니라 테마 자체도 메이저 버전이 업데이트된 상태였다.

- 현재 사용 버전 : 6.4.2
- 최신 릴리즈 : 7.5.0 (2026-03-16)

`wdm` 버전만 수정해 오류를 해결하는 방법도 있지만, 오래된 테마를 계속 유지하면 Ruby나 Gem이 업데이트될 때마다 비슷한 호환성 문제가 반복될 가능성이 높다.

장기적인 유지보수를 고려해 이번 기회에 Chirpy 테마를 최신 버전으로 업데이트하기로 결정했다.

다만 기존에는 테마 파일을 직접 수정하여 사용하고 있었기 때문에, 단순히 최신 버전으로 교체하는 것이 아니라 기존 설정과 직접 수정한 내용을 최대한 유지하면서 안전하게 업그레이드하는 것을 목표로 했다.

<br/>

## 🌿 업데이트용 브랜치 및 백업 브랜치 생성

메이저 버전 업데이트는 설정 파일과 파일 구조가 크게 변경될 수 있기 때문에, 문제가 발생하더라도 언제든지 이전 상태로 돌아갈 수 있도록 먼저 브랜치를 분리했다.

이번 작업에서는 다음 두 개의 브랜치를 생성했다.

| 브랜치                         | 용도                                                 |
| ------------------------------ | ---------------------------------------------------- |
| `rebuild/blog-on-chirpy-7.5.0` | Chirpy 7.5.0으로 마이그레이션 작업을 진행하는 브랜치 |
| `backup-20260619`              | 업데이트 전 상태를 그대로 보관하기 위한 백업 브랜치  |

```bash

# 업데이트 전 상태를 보관할 백업 브랜치 생성 및 이동
git switch -c backup-20260619

# 원격 저장소에 백업 브랜치 생성
git push -u origin backup-20260619

# 기존 브랜치(main)로 이동
git switch main

# 메이저 업데이트 작업용 브랜치 생성 및 이동
git switch -c rebuild/blog-on-chirpy-7.5.0

```

이후 과정에서 사용하는 명령어와 작업 내용은 모두 `rebuild/blog-on-chirpy-7.5.0` 브랜치를 기준으로 진행했으며, `main` 브랜치는 항상 기존 블로그가 동작하는 상태로 유지했다.

<br/>

## 🔗 Chirpy 공식 Repository와 연결

최신 Chirpy 테마를 적용하기 위해 먼저 [Chirpy 공식 Repository](https://github.com/cotes2020/jekyll-theme-chirpy)를 `upstream`으로 등록했다.

현재 블로그는 Chirpy를 Fork한 저장소가 아니기 때문에, 공식 Repository의 최신 릴리즈와 변경 사항을 가져오려면 별도의 원격 저장소를 등록해야 한다.

```bash
# Chirpy 공식 Repository를 upstream으로 등록
git remote add upstream https://github.com/cotes2020/jekyll-theme-chirpy.git

# 등록된 원격 저장소 확인
git remote -v

# 최신 태그와 변경 사항 가져오기
git fetch upstream --tags
```

> Git에서는 일반적으로 자신의 저장소를 `origin`, 원본 프로젝트를 `upstream`으로 등록한다.
>
> `upstream`을 등록하면 공식 프로젝트의 최신 릴리즈나 변경 사항을 손쉽게 가져오고 비교할 수 있다.

이후 `upstream`의 `v7.5.0` 태그를 기존 블로그에 병합하는 방식으로 업데이트를 시도했다. 하지만 메이저 버전 업데이트 과정에서 Git 히스토리와 프로젝트 구조 차이로 인해 충돌이 발생했고, 병합을 진행하더라도 더 이상 사용되지 않는 구버전 파일과 디렉터리가 그대로 남는 문제가 있었다.

결국 기존 프로젝트에 최신 테마를 병합하는 대신, **최신 Chirpy 7.5.0 소스를 그대로 적용한 뒤 기존 포스트와 설정 등 필요한 부분만 다시 이식하는 방식이 더 안전하다고 판단했다.**

<br/>

## 🧹 기존 프로젝트 정리

최신 Chirpy 소스를 적용하기 위해 기존 프로젝트 파일을 모두 정리했다.

```bash
git add .
git commit -m "chore: 테마 버전 업그레이드 시작, 기존 파일 모두 삭제"
git push --set-upstream origin rebuild/blog-on-chirpy-7.5.0
```

<br/>

## 📦 최신 Chirpy 소스 적용

기존 프로젝트 파일을 정리한 뒤, [Chirpy 7.5.0 소스 파일](https://github.com/cotes2020/jekyll-theme-chirpy/releases/tag/v7.5.0)을 다운로드하여 작업 브랜치에 그대로 적용했다.

적용 후 로컬에서 Jekyll 서버를 실행해 보니 다음과 같이 JavaScript 파일을 찾을 수 없다는 오류가 발생했다.

```bash
[2026-06-19 17:10:46] ERROR '/assets/js/dist/theme.min.js' not found.
[2026-06-19 17:10:46] ERROR '/assets/js/dist/home.min.js' not found.
```

Chirpy 7.5.0에서는 예전처럼 빌드된 JavaScript 파일이 저장소에 완성본으로 포함되어 있지 않았다. 대신 `npm`을 통해 프론트엔드 의존성을 설치하고, 필요한 JavaScript 파일을 직접 빌드해서 생성하는 구조였다.

```bash
# 프론트엔드 의존성 설치
npm install

# JavaScript/CSS 등 프론트엔드 리소스 빌드
npm run build

# Jekyll 로컬 서버 실행
bundle exec jekyll serve
```

`npm run build`를 실행하면 `assets/js/dist/` 아래에 `theme.min.js`, `home.min.js`와 같은 빌드 결과물이 생성되고, 이후 Jekyll 서버도 정상적으로 실행되었다.

<br/>

## 📝 기존 포스팅 이식

최신 Chirpy 적용이 완료된 후 기존 포스팅와 포스팅 asset 파일을 새로운 프로젝트로 가져왔다.

```text
_posts/
assets/img/posts_img/
```

기존 포스팅를 적용한 뒤 로컬에서 빌드를 진행하자 태그 페이지 생성 과정에서 충돌이 발생했다.

![image]({{ site.url }}{{ site.baseurl }}/assets/img/posts_img/2026-06-23-blog-02.png)

원인을 확인해 보니 기존 포스팅에서 `Java`와 `java`처럼 대소문자만 다른 태그를 함께 사용하고 있었다. Chirpy는 태그 URL을 생성할 때 모두 소문자로 변환하기 때문에 두 태그가 모두 `tags/java/`로 매핑되면서 동일한 경로에 파일을 생성하려고 시도한 것이다.

이번 기회에 태그와 카테고리 규칙을 새롭게 정립하고, 기존 포스팅도 모두 동일한 기준으로 정리해 일관성을 유지했다.

> 💡 **태그/카테고리 규칙**
>
> - 소문자 사용
> - 한글 사용 가능
> - 공백 사용 가능

<br/>

## ✅ 마무리

이번 포스팅에서는 최신 Chirpy 환경을 구성하고 기존 포스팅을 이식하는 과정까지 정리했다.

다음 포스팅에서는 기존 블로그에서 사용하던 커스텀 기능을 최신 버전에 맞게 다시 적용하는 과정을 정리한다.

<br/>

<!-- ➡️ [**Jekyll Chirpy Migration (2) - 기존 커스텀 기능 복원**](링크) -->
