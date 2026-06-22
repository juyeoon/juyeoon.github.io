---
title: "[Java] String.compareTo() - 문자열 사전 순 비교"
date: 2025-06-30 17:54:21 +09:00
categories: [java, 메서드]
tags: [java, string, compareto, String 메서드, 문자열, 사전순 정렬, 문자열 비교]
---

<!-- ========================================================================== -->

`String.compareTo()`로 문자열을 사전 순서로 비교할 수 있습니다.

<br>

<!-- ========================================================================== -->

## 📝 compareTo()

---

`String.compareTo()`는 두 문자열을 사전 순으로 비교할 때 사용하는 메서드로, 반환값은 다음과 같습니다:

- 0: 두 문자열이 동일함

- 양수: 호출한 문자열이 비교 대상보다 뒤에 옴

- 음수: 호출한 문자열이 비교 대상보다 앞에 옴

<br>

| 예제 1

```java
String s1 = "abc";
String s2 = "def";

System.out.println("\"abc\".compareTo(\"def\"): " + s1.compareTo(s2));
System.out.println("\"def\".compareTo(\"abc\"): " + s2.compareTo(s1));
System.out.println("\"abc\".compareTo(\"abc\"): " + s1.compareTo(s1));
```

| 예제 1 결과

```
"abc".compareTo("def"): -3
"def".compareTo("abc"): 3
"abc".compareTo("abc"): 0
```

<br>

`compareTo()`는 두 문자열을 문자 단위로 비교한 후, 다른 문자가 있으면 문자끼리 뺀 값(아스키코드)을 리턴합니다.

<br>

| 예제 2

```java
String s1 = "abc";
String s2 = "ebc";
String s3 = "agc";
String s4 = "abe";

System.out.println("\"abc\".compareTo(\"ebc\"): " + s1.compareTo(s2));
System.out.println("\"abc\".compareTo(\"agc\"): " + s1.compareTo(s3));
System.out.println("\"abc\".compareTo(\"abe\"): " + s1.compareTo(s4));
```

| 예제 2 결과

```
"abc".compareTo("ebc"): -4
"abc".compareTo("agc"): -5
"abc".compareTo("abe"): -2
```

<br>

문자열이 같은데 길이가 다르면, 두 문자열의 길이를 뺀 값을 리턴합니다.

<br>

| 예제 3

```java
String s1 = "abc";
String s2 = "abcdefg";

System.out.println("\"abc\".compareTo(\"abcdefg\"): " + s1.compareTo(s2));
System.out.println("\"abcdefg\".compareTo(\"abc\"): " + s2.compareTo(s1));
```

| 예제 3 결과

```
"abc".compareTo("abcdefg"): -4
"abcdefg".compareTo("abc"): 4
```

<br>

<!-- ========================================================================== -->

## ✨ 핵심 포인트

---

정리하자면,

> `s1.compareTo(s2)`는 앞에서부터 다른 문자를 찾고 다른 문자가 있으면, `s1의 해당 문자 - s2의 해당 문자` 값을 리턴합니다.

> 만약 다른 문자가 없으면 `s1의 길이 - s2의 길이`를 리턴합니다.

<br>

<!-- ========================================================================== -->

## 🔗 문서 & 참고 링크

---

- [[Java] String - compareTo : 문자열 사전순 비교](https://priming.tistory.com/7)

<br>
