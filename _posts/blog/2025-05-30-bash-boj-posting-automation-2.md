---
title: "[Github Blog] 자동 생성된 포스트를 vscode로 자동으로 열기"
date: 2025-05-30 18:37:00 +09:00
categories: [Blog, Posting]
tags: [github, blog, shell, bash, 자동화, 백준, vscode]
---

👉 이전 포스트:  
[문제 풀이 포스트 자동 생성 자동화 과정 정리](https://juyeoon.github.io/posts/bash-boj-posting-automation/)

이전 포스트에서 자동으로 생성된 포스트가 생성된 후 vscode 열리는 것도 자동화하면 편하겠다는 생각이 들어서 기존 스크립트를 수정하여 이 작업을 추가하였습니다.

<br>

## ✅ 추가한 기능

스크립트가 포스트 파일을 생성한 뒤, **자동으로 vscode에서 열어줍니다.**

<br>

## 🖥 추가한 코드

```bash
# VS Code로 자동 열기
POST_PATH="$POST_DIR/$FILENAME"
code "$POST_PATH"
```

<br>

## 💡 주의 사항

- `code` 명령어가 작동하려면 vscode가 설치되어 있어야 하며,  
  CLI에서 사용할 수 있도록 PATH에 등록되어 있어야 합니다.

![Image](https://github.com/user-attachments/assets/c77355eb-1a75-4545-9b62-e1b884652b04)

<small>▲ code 명령어 작동 확인</small>

---

<br>

## ✨ 마무리

이제는 포스트를 자동으로 생성할 뿐만 아니라, 매번 다르게 적어야 하는 문제 풀이를 적기 위해 에디터를 여는 작업도 자동화 하여 더 편리해졌습니다.

앞으로도 포스팅을 하며 느끼는 불편함들을 하나씩 자동화해가는 것이 목표입니다.

<br>
