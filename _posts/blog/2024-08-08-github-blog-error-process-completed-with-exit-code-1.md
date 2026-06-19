---
title: "[Github Blog] 'Error: Process completed with exit code 1.' (해결)"
date: 2024-08-08 17:39:00 +09:00
categories: [Blog, Error]
tags: [github, blog, error]
---

## **문제**

![image]({{ site.url }}{{ site.baseurl }}/assets/img/posts_img/2024-08-08-blog-01.png)

블로그에 새로운 포스트를 작성하고 제대로 올라갔나 확인하려고 레파지토리에 들어갔는데 커밋 로그에 'x'가 되어있었다.

빌드 과정에서 문제가 생긴 듯 한데 위의 사진처럼 경로가 쭉쭉쭉 나오더니 마지막에 `Error: Process completed with exit code 1.`라고 알려줬다.

오랜만의 포스팅이긴 하지만 그 사이에 블로그 시스템에 문제가 생긴 것 같지도 않고 에러 메세지가 간단해서 뭔가 다른 사람들도 자주 볼 수 있는 메세지라고 생각해서 일단 에러 메세지를 검색을 해봤다.

---

## **해결 방법**

![image]({{ site.url }}{{ site.baseurl }}/assets/img/posts_img/2024-08-08-blog-02.png)

**<U>원인은 포스트 글 설정에서 문제가 생겼던 모양.</U>**

문제 번호를 숫자로만 이루어진 태그를 넣고 싶어서 그냥 숫자만 적었더니 그 부분에서 문제가 생긴 듯해서 작은따옴표('')로 감싸주었다. (태그엔 문자열만 넣어야 하나보다)

이전 포스트까지는 'nnnn번' 이런 식으로만 넣었어서 이번 포스팅에서 문제가 발생한 듯하다.

---

## **참고 사이트**

<a href="https://cometj03.github.io/posts/github-actions-process-completed-exitcode1/">(해결) Github Actions Error - "Process completed with exit code 1."</a>
