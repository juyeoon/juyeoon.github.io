---
title: "[기록] GitHub 빌드 실패 해결하기"
date: 2025-07-02 21:47:04 +09:00
categories: [Blog, Error]
tags: [github, blog, error, build failed]
---

<!-- ========================================================================== -->

7월 1일부터 갑자기 GitHub 블로그 빌드가 실패하기 시작했다.  
기존에 잘 사용하던 템플릿으로 텍스트만 바꿔서 포스트를 작성했을 뿐인데, 어느 순간부터 배포가 되지 않았다.  

![Image]({{ site.url }}{{ site.baseurl }}/assets/img/posts_img/2025-07-02-blog-01.png)

이번 글에서는 해당 문제의 원인을 추적하고 해결한 과정을 기록해 본다.

<br>

<!-- ========================================================================== -->

## 🚨 빌드 에러 발생

---

포스팅 내용은 단순히 제목만 바꿨을 뿐인데, 갑작스럽게 빌드 에러가 발생했다.  

빌드 로그를 확인해보니까 아래와 같은 에러 메시지가 확인되었다.

```
* At _site/posts/boj-30684-java/index.html:116:
```

![Image]({{ site.url }}{{ site.baseurl }}/assets/img/posts_img/2025-07-02-blog-02.png)

해당 파일을 확인해보았다. 

에디터를 사용해서 파일 자체를 확인해보니까 라인이 맞지 않았다.

![Image]({{ site.url }}{{ site.baseurl }}/assets/img/posts_img/2025-07-02-blog-03.png)

로컬에서 개발자 모드로 확인한 결과, 다음과 같은 빈 링크가 존재하고 있었다.

```html
<a href=""></a>
```

![Image]({{ site.url }}{{ site.baseurl }}/assets/img/posts_img/2025-07-02-blog-04.png)

검색해보니 Jekyll에서 빈 링크가 있을 경우 빌드가 실패할 수 있다는 것을 확인했다.  
[관련 이슈 참고](https://github.com/cotes2020/jekyll-theme-chirpy/issues/1403)

<br>

<!-- ========================================================================== -->

## 1️⃣ 해결하자 1: 테스트 브랜치 생성 및 테스트

---

로컬에서 페이지만 확인했을 땐 잘 보이지만 원격 repo에 올리면 빌드가 실패했기 때문에, `hotfix/build-error`라는 새로운 브랜치를 생성해서 테스트를 진행했다. 

지금 빌드되는 브랜치가 `main`으로 잡혀있기 때문에 블로그에 접속해서 확인해보려면 설정을 바꿔야 한다.

repo - Settings - Pages - Build and deployment에서 브랜치를 새로 만든 브랜치로 바꿔주고 테스트를 시작했다.

![Image]({{ site.url }}{{ site.baseurl }}/assets/img/posts_img/2025-07-02-blog-05.png)

테스트 시작.

에러가 발생한 `.md` 파일을 확인해보니 링크 라인과 주석 라인이 한 줄로 인식되게 적혀있었다.

![Image]({{ site.url }}{{ site.baseurl }}/assets/img/posts_img/2025-07-02-blog-06.png)

마크다운 문법상 줄바꿈을 하려면 줄 끝에 공백 두 칸을 추가하거나 명시적으로 빈 줄을 넣어야 한다. 그렇지 않으면 연속된 라인으로 처리된다.

![Image]({{ site.url }}{{ site.baseurl }}/assets/img/posts_img/2025-07-02-blog-07.png)

로컬 서버를 열어서 확인해보면 `<a href>`가 제거된 것을 볼 수 있다.

![Image]({{ site.url }}{{ site.baseurl }}/assets/img/posts_img/2025-07-02-blog-08.png)

그래서 원격 repo에 push해서 빌드가 잘 되는지 확인해본다. 

업로드 후 에러 없이 정상적으로 빌드되었음을 확인했다.

![Image]({{ site.url }}{{ site.baseurl }}/assets/img/posts_img/2025-07-02-blog-09.png)

하지만 블로그 접속 시 반영이 되지 않아 브랜치 설정 문제를 의심하게 되었다.  

<br>

<!-- ========================================================================== -->

## 2️⃣ 해결하자 2: 브랜치 설정 문제

---

브랜치 설정 문제를 확인하기 위해서 테스트 페이지를 현재 depoly branch로 설정되어 있는 `hotfix/build-error`에 테스트 페이지를 업로드 했다.

![Image]({{ site.url }}{{ site.baseurl }}/assets/img/posts_img/2025-07-02-blog-10.png)

이것 역시 빌드는 잘 되는데 블로그에 적용이 안 된다.

`main` 브랜치에도 같은 테스트 페이지를 업로드 해본다.

![Image]({{ site.url }}{{ site.baseurl }}/assets/img/posts_img/2025-07-02-blog-11.png)

테스트 페이지에는 링크를 거는 내용이 없음에도 또 `<a>` 태그가 문제라는 에러가 뜬다.

그럼 각각 포스팅의 문제가 아니라는 뜻이다. 

(물론 위에서 말한 링크 라인과 주석 라인이 한 줄로 인식되게 적혀있었는 건 수정을 하긴 해야한다.)

<br>

<!-- ========================================================================== -->

## 3️⃣ 해결하자 3: 블로그 테마 설정 되돌리기 (롤백)

빌드 실패가 처음 발생한 시점 전에 변경한 내용을 살펴보니까 카테고리 세분화를 하기 위해서 카테고리 구조를 바꿨었다. 

![Image]({{ site.url }}{{ site.baseurl }}/assets/img/posts_img/2025-07-02-blog-12.png)

그리고 `9cb305c` 커밋으로 올린 글 말고 전부 404가 뜨고 있었다. 

이걸로 유추하기론 높은 확률로 이 부분이 문제인 것 같다. (수정을 하면서도 찝찝하긴 했다.)

카테고리 설정 바꾼 것이 꼭 필요한 수정이 아니었던지라 그냥 설정 파일 변경 전으로 커밋 롤백을 진행하기로 했다. 

롤백 전에 백업용 브랜치 생성했다. 

![Image]({{ site.url }}{{ site.baseurl }}/assets/img/posts_img/2025-07-02-blog-13.png)

그 다음 문제 발생 전 커밋(`bb8536e` 커밋)으로 강제 롤백을 진행했다.

![Image]({{ site.url }}{{ site.baseurl }}/assets/img/posts_img/2025-07-02-blog-14.png)

롤백 진행 시 강제 푸시를 진행하기 때문에 협업 시에는 함부로 진행하면 안 되지만 혼자 쓰는 블로그용 repo기 때문에 그냥 사용했다.

(협업 시 사용하면 공동 작업자의 커밋을 날려버릴 수 있음)

```bash
git reset --hard [커밋 해시]

git push origin main --force
```

![Image]({{ site.url }}{{ site.baseurl }}/assets/img/posts_img/2025-07-02-blog-15.png)

롤백 끝.

![Image]({{ site.url }}{{ site.baseurl }}/assets/img/posts_img/2025-07-02-blog-16.png)

## 4️⃣ 해결하자 4: 롤백한 커밋 재배포 하기

롤백은 그냥 커밋만 되돌린 것이기 때문에 자동으로 배포가 되지 않는다.

그래서 빈 커밋을 하나 만들어줬다.

```bash
git commit --allow-empty -m "trigger redeploy"

git push origin main
```

![Image]({{ site.url }}{{ site.baseurl }}/assets/img/posts_img/2025-07-02-blog-17.png)

근데 빌드 진행이 안 됐다.

![Image]({{ site.url }}{{ site.baseurl }}/assets/img/posts_img/2025-07-02-blog-18.png)

아마 파일이 수정되어야 자동 배포가 진행되는 것 같다. 

그래서 그냥 의미 없는 수정을 하고 커밋을 했다.

![Image]({{ site.url }}{{ site.baseurl }}/assets/img/posts_img/2025-07-02-blog-19.png)

정상적으로 배포가 됐고 404뜨던 게시글들도 다 잘 보였다.

![Image]({{ site.url }}{{ site.baseurl }}/assets/img/posts_img/2025-07-02-blog-20.png)

역시 구조는 함부로 건드는 것이 아니다...

## 5️⃣ 해결하자 5: 백업 브랜치에서 필요한 커밋 가져오기 (cherry-pick)

롤백을 하면서 사라진 포스트들이 있기 때문에 `backup` 브랜치에서 `cherry-pick`으로 필요한 커밋들을 가져온다.

```bash
git cherry-pick [커밋 해시]

git push origin main
```

![Image]({{ site.url }}{{ site.baseurl }}/assets/img/posts_img/2025-07-02-blog-21.png)

적용 완료.

![Image]({{ site.url }}{{ site.baseurl }}/assets/img/posts_img/2025-07-02-blog-22.png)

빌드도 잘 되었고, 블로그도 정상적으로 동작한다! 

![Image]({{ site.url }}{{ site.baseurl }}/assets/img/posts_img/2025-07-02-blog-23.png)

### 👍 오늘도 해결! 👍

## ✨ 핵심 포인트

---

- 로컬에서는 잘 보여도 빌드 과정에서 문제가 생길 수 있다. 

- Jekyll 테마에 따라 빈 `<a>` 태그는 빌드 오류를 유발할 수 있다. 

- 문제 해결을 할 땐 브랜치를 나눠서 테스트하자. 

- ⭐ 구조는 함부로 건드는 것이 아니다. 

- 지금 블로그 설정으로는 파일이 변경되어야 자동으로 배포된다. 

- `--allow-empty`로 파일 수정 없이 빈 커밋을 생성할 수 있다. 

- `cherry-pick`으로 원하는 커밋만 가져올 수 있다. 

<br>

<!-- ========================================================================== -->

