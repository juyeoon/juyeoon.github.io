---
title: "[Github Blog] 'Error: Missing download info for actions/upload-artifact@v3.' (해결)"
date: 2025-05-27 18:01:00 +09:00
categories: [Blog, Error]
tags: [github, blog, error]
---

## **문제**

![Image](https://github.com/user-attachments/assets/e86b9313-3da6-4abc-a873-63e5275c0530)

오랜만에 블로그에 새로운 포스트를 작성하고 제대로 올라갔나 확인하는데 빌드 에러가 발생했음.

<br>

## **해결 방법**

**<U>원인: GitHub Actions의 `actions/upload-artifact@v3`는 오래된 버전이고, GitHub의 기본 런타임 환경이 변경돼서 오래된 액션은 호환되지 않아 생기는 문제라고 함.</U>**

![Image](https://github.com/user-attachments/assets/1a8fc996-77d1-417e-980a-eb30ec5eea44)

![Image](https://github.com/user-attachments/assets/7bd8355a-7c64-4a6a-a3ff-b28a5bcd3dfe)

[이 스레드](https://github.com/orgs/community/discussions/152695)의 위의 글을 참고해서 코드를 수정하여 다시 커밋하니 잘 올라가는 것을 확인할 수 있었음.

<br>

- 적용한 수정 사항:

  `.github/workflows/pages-deploy.yml`의

  - `uses: actions/configure-pages@v3` -> `uses: actions/configure-pages@v4`

  - `uses: actions/upload-pages-artifact@v1` -> `uses: actions/upload-pages-artifact@v3`

  - `uses: actions/deploy-pages@v2` -> `uses: actions/deploy-pages@v4`

<br>

## **참고 사이트**

<a href="https://github.com/orgs/community/discussions/154894">workflows /r.yml: Missing download info for actions/upload-artifact@v3 #154894</a>

<a href="https://github.com/orgs/community/discussions/152695">build Missing download info for actions/upload-artifact@v3 #152695</a>
