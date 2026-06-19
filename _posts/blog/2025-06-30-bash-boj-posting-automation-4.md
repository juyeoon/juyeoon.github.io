---
title: "[Github Blog] 자동 포스팅 생성 시 기타 옵션"
date: 2025-06-30 17:05:16 +09:00
categories: [Blog, Posting]
tags: [github, blog, shell, bash, 자동화, windows, git-bash, 포스팅]
---

<!-- ========================================================================== -->

👉 이전 포스트:

[1. 문제 풀이 포스트 자동 생성 자동화](https://juyeoon.github.io/posts/bash-boj-posting-automation/)

[2. 생성된 포스트를 vscode로 자동 열기](https://juyeoon.github.io/posts/bash-boj-posting-automation-2/)

[3. Git Bash 스크립트를 아이콘 클릭으로 실행하기](https://juyeoon.github.io/posts/bash-boj-posting-automation-3/)


이전 포스팅에서 아이콘 클릭으로 알고리즘 풀이 포스팅을 자동으로 생성하는 작업을 정리해봤습니다. 

최근에 범용으로 사용할 수 있는 포스팅 템플릿에 현재 시각(date)을 입력하여 포스팅을 자동으로 생성하는 작업을 진행하면서, 이전 포스팅에서 사용하지 않은 다른 옵션들을 정리해 볼까 합니다.  

<br>

<!-- ========================================================================== -->

## 🗂️ vscode 폴더로 열기

---

이전 포스팅에서 [포스트를 생성하고 바로 vscode로 해당 파일을 여는 작업](https://juyeoon.github.io/posts/bash-boj-posting-automation-2/)을 했었는데, 이번엔 범용 템플릿을 자동으로 만들었기 때문에 `post` 폴더 자체를 여는 것이 좋을 것 같아서 vscode를 여는 방법을 바꿔 보았습니다.

| 수정 전 - 파일을 열기

```bash
POST_DIR="$(cd "$(dirname "$0")" && pwd)"
POST_PATH="$POST_DIR/$FILENAME"

code "$POST_PATH" # vscode 열기
```

| 수정 후 - 폴더를 열기
```bash
POST_DIR="$(cd "$(dirname "$0")" && pwd)"

code "$POST_DIR" # vscode 열기
```

<br>

<!-- ========================================================================== -->

## 🔢 파일 생성할 때 index 번호 붙이기

---

알고리즘 포스팅은 문제 번호에 따라 파일명이 달라지기 때문에 덮어쓰기 문제가 발생하지 않지만, 범용 포스팅은 날짜만으로 파일명이 결정되어 여러 번 생성하면 동일한 파일이 계속 덮어써집니다.

이런 문제를 해결하기 위해 INDEX 변수를 활용해, 포스팅을 생성할 때마다 제목 끝에 순번이 자동으로 붙도록 설정해두었습니다.

`printf -v`를 사용해서 순번이 `01`, `02`, ..., `12` 이런 포맷으로 만들어지도록 했습니다. 

그리고 `while` 반복문으로 동일한 이름의 파일이 존재하면 `INDEX`를 하나씩 올려서 파일 이름을 재설정합니다. 

```bash
# 포스팅 파일 이름 설정하기
DATE_STR=$(date "+%Y-%m-%d")
BASENAME="${DATE_STR}-posting-name" # 기본 이름
EXTENSION=".md" # 확장자
INDEX=1 # 순번
printf -v FILENAME "%s-%02d%s" "$BASENAME" "$INDEX" "$EXTENSION" # 파일 이름

# 동일 이름 파일이 존재하면 번호 증가
while [ -e "$POST_DIR/$FILENAME" ]; do
  INDEX=$((INDEX + 1))
  printf -v FILENAME "%s-%02d%s" "$BASENAME" "$INDEX" "$EXTENSION"
done
```

<br>

<!-- ========================================================================== -->

## 🔚 쉘 스크립트 실행 터미널 자동 종료

---

[3. Git Bash 스크립트를 아이콘 클릭으로 실행하기](https://juyeoon.github.io/posts/bash-boj-posting-automation-3/) 포스팅에서 git-bash 바로가기를 클릭하여 쉘 스크립트를 실행하도록 설정하였는데, 기존엔 로그를 보기 위해서 터미널이 꺼지지 않고 유지되도록 설정했습니다. 하지만 사용하다 보니까 일정 시간 뒤에 자동으로 꺼지면 좋을 것 같아서 속성을 수정하였습니다.

```
"C:\Program Files\Git\git-bash.exe" -c "bash -i './create-general-post.sh'; sleep 3"
```

쉘 스크립트 실행에 관련된 명령어는 git-bash 바로가기의 [속성] - [대상]을 수정하면 되는데 `read` 명령어를 삭제하고 `sleep` 명령어를 추가하여 바로 종료되지 않고 일정 시간동안 유지된 후 종료되게 설정하였습니다. 

+ `read` 명령어

    + 사용자의 입력을 기다립니다.

    + 사용자가 입력하기 전까지는 스크립트가 멈춘 채로 대기합니다.

+ `sleep` 명령어

    + 아무 입력 없이 지정된 시간동안 정지(대기)합니다.

<br>

<!-- ========================================================================== -->

<!-- ## ✨ 핵심 포인트

---

<!-- 📝내용📝 -->

<br> -->

<!-- ========================================================================== -->

<!-- ## 🔗 문서 & 참고 링크

---

- []()

- []()

<br> -->

