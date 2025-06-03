---
title: "[Github Blog] Git Bash 스크립트를 아이콘 클릭으로 실행하기"
date: 2025-06-03 17:12:00 +09:00
categories: [Blog, Posting]
tags: [github, blog, shell, bash, 자동화, 백준, windows, git-bash, 바로가기]
---

👉 이전 포스트:

[1. 문제 풀이 포스트 자동 생성 자동화](https://juyeoon.github.io/posts/bash-boj-posting-automation/)
[2. 생성된 포스트를 vscode로 자동 열기](https://juyeoon.github.io/posts/bash-boj-posting-automation-2/)

이전 포스트에서 만든 스크립트는 Git Bash를 우클릭해서 열고 명령어를 입력해 실행하는 방식으로 계속 사용하고 있었습니다. 하지만 입력 없이 자동으로 동작하는 스크립트이기 때문에 단순 클릭만으로 실행되면 훨씬 편리하겠다는 생각이 들었고, 이를 개선해보게 되었습니다.

<br>

## ✅ 추가한 기능

Git Bash 바로가기를 만들어, **아이콘을 실행하면 포스트 생성 스크립트가 자동으로 실행되도록 구성했습니다.**

<br>

## ✅ 자동 실행 구성 단계

1. **Git Bash 바로가기(.lnk) 만들기**

2. **바로가기 속성 수정**

3. **스크립트 실행 확인**

<br>

## 🧱 1. Git Bash 바로가기(.lnk) 만들기

먼저 바로가기를 만들 `git-bash.exe`의 경로를 확인해야 합니다.

시작 메뉴에서 **Git Bash**를 검색한 뒤, **파일 위치 열기**를 선택하면 바로가기 파일이 있는 위치로 이동합니다.

![Image](https://github.com/user-attachments/assets/b506f27d-6598-425d-86ca-6204aeed48d1)
![Image](https://github.com/user-attachments/assets/38db76a5-9d09-4015-9e23-e710f3cc6c06)

해당 바로가기 아이콘을 우클릭한 뒤 **속성**을 확인하면, 실제 실행 파일 경로를 확인할 수 있습니다.

```
C:\Program Files\Git\git-bash.exe
```

![Image](https://github.com/user-attachments/assets/3a53dfbf-ead3-4154-9e16-ce2619f71fb3)

이제 이 경로를 바탕으로 **`git-bash.exe`의 위치를 찾은 후**, 해당 `git-bash.exe` 파일을 우클릭하고 **"보내기 → 바탕화면에 바로 가기 만들기"**를 선택하여 바탕화면에 바로가기를 생성합니다.

![Image](https://github.com/user-attachments/assets/3cf41103-337d-4066-9b1c-baff217908cf)

마지막으로, 바탕화면에 생성된 이 **바로가기 파일을 실행할 쉘 스크립트가 있는 폴더(`...\_posts\boj\`)로 이동**시킵니다.

또한, 스크립트 용도에 맞게 바로가기 파일의 이름도 함께 바꿔줍니다.

![Image](https://github.com/user-attachments/assets/6665778d-0e77-444e-ba17-8c6ad1ff1db6)

<br>

## ⚙️ 2. 바로가기 속성 수정

바로가기 아이콘을 **우클릭 → 속성**으로 들어가, 아래와 같이 **대상** 항목과 **시작 위치** 항목을 수정합니다.

![Image](https://github.com/user-attachments/assets/843f3534-70b6-416a-bf01-71a9012edeed)

### 대상

> 바로가기가 실행할 실제 프로그램이나 명령어 전체를 지정하는 항목입니다.

```
"C:\Program Files\Git\git-bash.exe" -c "bash -i './create-boj-post.sh'; read -p 'Press enter to close...'"
```

- `"git-bash.exe"`: Git Bash 실행 파일

- `-c`: 실행할 명령어를 전달하는 옵션

- `bash -i './create-boj-post.sh'`: 대화형 셸(`-i`)로 현재 폴더에 있는 `.sh` 파일 실행

- `read -p 'Press enter to close...'`: 실행 결과를 확인할 수 있도록 사용자 입력을 기다림으로써 창이 자동으로 닫히지 않게 함

### 시작 위치

> 바로가기를 실행할 때 **작업 디렉토리**를 지정하는 항목입니다.

```
D:\juyeoon.github.io\_posts\boj
```

이 위치는 실행할 스크립트가 존재하는 디렉토리입니다.  
`./create-boj-post.sh`처럼 상대 경로로 실행하려면 **시작 위치가 정확해야 하므로**, 스크립트 파일이 있는 폴더로 지정해줍니다.

이 설정을 통해 Git Bash는 해당 폴더에서 스크립트를 실행하게 되고, 별도의 경로 이동 없이 바로 실행이 가능해집니다.

<br>

## 🧪 3. 스크립트 실행 확인

바로가기 아이콘을 더블클릭하면 Git Bash 창이 열리고, `create-boj-post.sh` 스크립트가 자동으로 실행되는 것을 확인할 수 있습니다.

스크립트의 출력 결과가 정상적으로 표시되고, `read` 명령어 덕분에 창이 바로 닫히지 않고 일시 정지 상태로 유지됩니다.

![Image](https://github.com/user-attachments/assets/273fcd4c-16a7-481a-a65a-f30544164c03)

<br>

## 📁 [추가] `.gitignore` 구성

포스트가 생성되는 폴더에 바로가기가 존재하기 때문에 `.gitignore`를 작성하여 커밋 대상에서 제외했습니다.

```gitignore
...

.lnk

```

<br>

## ✨ 마무리

이전까지는 Git Bash를 열고 직접 명령어를 입력해야 했지만, 이제는 바로가기 아이콘을 클릭하는 것만으로 스크립트가 자동 실행되도록 구성했습니다.

앞으로도 작은 불편들을 계속 개선해나가면 좋을 것 같습니다.

<br>
