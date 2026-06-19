---
title: "[Github Blog] Bash로 백준 풀이 포스팅 자동화하기"
date: 2025-05-29 22:30:00 +09:00
categories: [Blog, Posting]
tags: [github, blog, shell, bash, 자동화, 백준]
---

> 매번 반복되는 백준 알고리즘 풀이 포스트를 작성할 때 사용할 수 있는 자동화 스크립트를 작성해봤습니다. 문제 정보가 있는 파일을 읽어 마크다운 형식의 포스트 템플릿에 값이 적용되어 포스트가 자동으로 생성됩니다.

<br>

## ✅ 왜 자동화를 하게 되었나?

평소 GitHub 블로그에 백준 문제 풀이를 기록하고 있었는데, 수동으로 포스트를 생성하면 여러 값들을 일일이 바꿔줘야하는 번거로움이 있었습니다.

그래서 **템플릿 + 변수 파일 + 쉘 스크립트** 조합으로 자동화했습니다.

자동화는 아래의 항목에 대해 수행됩니다.

- 날짜를 파일 이름에 적용하여 파일 생성

- 포스트 제목, 날짜, 카테고리, 테그 입력

- 템플릿 붙여넣기

- 코드 파일 입력

<br>

## ✅ 자동화 흐름 요약

1. **포스트 템플릿 작성**

2. **문제 정보 파일 작성**

3. **쉘 스크립트 작성**

4. **Git Bash에서 실행**

<br>

## 🧱 1. 포스트 템플릿 작성

원래 사용하던 템플릿에서 수동으로 바꿔줘야 했던 부분들을 `{{PROBLEM_ID}}`, `{{PROBLEM_NAME}}`, `{{CODE}}` 등의 마커로 표시하였습니다.

쉘 스크립트는 sed 명령을 통해 이러한 마커를 실제 값으로 동적으로 치환하며, 이를 통해 템플릿 기반의 마크다운 포스트를 자동으로 생성할 수 있습니다.

````markdown
---
title: "[BOJ/백준] {{PROBLEM_ID}}번 : {{PROBLEM_NAME}} (Java)"
date: {{POST_DATE_TIME}}
categories: [알고리즘, Java]
tags: [알고리즘, Java, BOJ, 백준, {{PROBLEM_TIER}}, {{PROBLEM_ID}}번, {{PROBLEM_TYPE}}]
---

...

## ✅ 코드 (Java)

```java
{{CODE}}
```
````

<br>

## 🧾 2. 문제 정보 파일 작성

problem-info.txt는 기존에 별도로 관리하던 문제 정보를 그대로 활용할 수 있도록 커스터마이징된 형식으로 구성하였습니다.

문제 풀이 후, 문제 번호, 제목, 난이도, 태그, 코드 파일명 등의 정보를 정해진 순서에 맞춰 텍스트 파일에 붙여넣기만 하면 스크립트에서 자동으로 파싱하여 사용할 수 있도록 설계되어 있습니다.

문제 정보 파일은 총 4줄로 구성됩니다.

| 줄  | 내용                | 변수명                       |
| --- | ------------------- | ---------------------------- |
| 1   | 문제번호 - 문제제목 | `PROBLEM_ID`, `PROBLEM_NAME` |
| 2   | 난이도              | `PROBLEM_TIER`               |
| 3   | 문제 유형           | `PROBLEM_TYPE`               |
| 4   | 코드 파일명         | `CODE_FILE_NAME`             |

<br>

## 🖥 3. 쉘 스크립트 작성

스크립트는 아래와 같은 과정으로 수행됩니다.

- 템플릿(`boj-template.md`), 문제 정보(`problem-info.txt`) 파일 존재 확인 및 읽기

- 문제 정보 파일에서 값 읽고 변수 저장

- 문제 번호로 코드가 저장된 경로 설정

- 코드 파일 경로 설정 및 파일 존재 확인

- 포스팅 파일 이름 설정

- 템플릿을 복사하고 값 치환

- 포스트 생성

<details>
<summary>포스트 생성 스크립트 보기</summary>

```bash
#!/bin/bash

# 현재 스크립트가 위치한 디렉토리 절대 경로
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

# 파일 경로 변수
POST_DIR="$SCRIPT_DIR"  # 결과 포스트 파일 저장 경로
POST_TEMPLATE="$SCRIPT_DIR/boj-template.md"
INFO_FILE="$SCRIPT_DIR/problem-info.txt"

# 변수 파일 존재 여부 확인
if [ ! -f "$INFO_FILE" ]; then
  echo "❌ 변수 파일이 존재하지 않습니다: $INFO_FILE"
  exit 1
fi

# 템플릿 파일 존재 및 읽기 확인
if [ ! -f "$POST_TEMPLATE" ]; then
  echo "❌ 템플릿 파일이 존재하지 않습니다: $POST_TEMPLATE"
  exit 1
fi

if [ ! -r "$POST_TEMPLATE" ]; then
  echo "❌ 템플릿 파일을 읽을 수 없습니다: $POST_TEMPLATE"
  exit 1
fi

# 변수 순서대로 읽기
{
  read -r PROBLEM_ID_NAME
  read -r PROBLEM_TIER
  read -r PROBLEM_TYPE
  read -r CODE_FILE_NAME
} < "$INFO_FILE"

# 문제 번호와 이름 분리 (구분자 " - ")
IFS=" - " read -r PROBLEM_ID PROBLEM_NAME <<< "$PROBLEM_ID_NAME"

# 양쪽 공백 제거
PROBLEM_ID=$(echo "$PROBLEM_ID" | xargs)
PROBLEM_NAME=$(echo "$PROBLEM_NAME" | xargs)
PROBLEM_TIER=$(echo "$PROBLEM_TIER" | xargs)
PROBLEM_TYPE=$(echo "$PROBLEM_TYPE" | xargs)
CODE_FILE_NAME=$(echo "$CODE_FILE_NAME" | xargs)

# 코드 파일 경로 설정
CODE_FOLDER_ID=$(( (PROBLEM_ID / 1000) * 1000 ))
CODE_FOLDER_NAME=$(printf "B%05d" "$CODE_FOLDER_ID")
CODE_PATH="/d/git_Algorithm/Algorithm/${CODE_FOLDER_NAME}/${CODE_FILE_NAME}.java"

# 코드 파일 확인
echo "📂 코드 경로: $CODE_PATH"
# 존재 + 읽기 확인
if [ -f "$CODE_PATH" ] && [ -r "$CODE_PATH" ]; then
  echo "✅ 코드 파일을 읽을 수 있습니다."
else
  echo "❌ 코드 파일이 없거나 읽을 수 없습니다."
  exit 1
fi

# 포스팅 날짜
POST_DATE_TIME=$(date "+%Y-%m-%d %H:%M:%S %:z")

# 포스팅 파일 이름
DATE_STR=$(date "+%Y-%m-%d")
LANGUAGE="java"
FILENAME="${DATE_STR}-boj-${PROBLEM_ID}-${LANGUAGE}.md"

# 템플릿 치환 및 코드 삽입
mkdir -p "$POST_DIR"
sed -e "s/{{POST_DATE_TIME}}/${POST_DATE_TIME}/" \
    -e "s/{{PROBLEM_ID}}/${PROBLEM_ID}/" \
    -e "s/{{PROBLEM_NAME}}/${PROBLEM_NAME}/" \
    -e "s/{{PROBLEM_TIER}}/${PROBLEM_TIER}/" \
    -e "s/{{PROBLEM_TYPE}}/${PROBLEM_TYPE}/" \
    -e "/{{CODE}}/{
        r ${CODE_PATH}
        d
    }" \
    "$POST_TEMPLATE" > "$POST_DIR/$FILENAME"

echo "✅ 블로그 포스트 생성 완료: $POST_DIR/$FILENAME"

```

</details>

<br>

## ✅ 실행 방법

자동화 도구 파일들은 경로 설정과 관리를 편하게 하기 위해서 포스트가 생성되는 폴더에 만들었습니다.

Bash Shell에서 해당 폴더로 이동 후 명령어를 실행합니다.

```bash
chmod +x create-boj-post.sh      # 최초 1회만 (실행 권한)
./create-boj-post.sh             # 매번 실행
```

![Image]({{ site.url }}{{ site.baseurl }}/assets/img/posts_img/2025-05-29-blog-01.png)

<br>

## 📁 `.gitignore` 구성

포스트가 생성되는 폴더에 존재하기 때문에 `.gitignore`를 작성하여 커밋 대상에서 제외했습니다.

```gitignore
create-boj-post.sh
boj-template.md
problem-info.txt
```

<br>

## ✨ 마무리

이제 문제 정보만 바꿔서 넣어주면, 템플릿이 적용된 포스트가 자동으로 생성됩니다.

그때그때 문제 풀이만 작성해 넣으면 되기 때문에, 포스팅에 드는 시간을 크게 줄일 수 있었습니다.

매일 문제는 풀고 있었지만 포스팅은 손이 많이 가서 자꾸 미루게 됐는데, 이제는 훨씬 간편하게 정리할 수 있어서 만족스럽습니다.

이후에는 파일 생성 후 바로 vscode를 여는 기능도 추가할 예정입니다.

<br>
