---
title: "[solvesql] 사랑에 대한 영화 찾기 (MySQL)"
date: 2026-06-30 10:47:18 +09:00
categories: [sql, solvesql]
tags:
  [sql, solvesql, solvesql level 1, mysql]
---

  <br>

🌸 solvesql - "사랑에 대한 영화 찾기" 풀이 (MySQL)

  <br>

<center><a href="https://solvesql.com/problems/movies-about-love/" style = 'font-size : 1.18rem; font-weight : 900'>solvesql - 사랑에 대한 영화 찾기</a></center>

  <br>

## 📌 **문제 요약**

영화 제목에 `Love` 또는 `love`가 포함된 영화의 제목, 개봉 연도, 로튼 토마토 평점을 조회하는 문제이다.

- 조건
  - 제목에 `Love` 또는 `love`가 포함된 영화만 조회한다.
  - 조회 컬럼은 영화 제목, 개봉 연도, 로튼 토마토 평점이다.
  - 로튼 토마토 평점 내림차순으로 정렬한다.
  - 평점이 같으면 개봉 연도 내림차순으로 정렬한다.


  <br>

## ✅ **풀이**

- `SELECT` 영화 제목, 개봉 연도, 로튼 토마토 평점
- `FROM` movies
- `WHERE` 제목에 `Love` 또는 `love`가 포함
- `ORDER BY` 로튼 토마토 평점 내림차순, 개봉 연도 내림차순;

  🔽

- `SELECT` 영화 제목, 개봉 연도, 로튼 토마토 평점
- `FROM` movies
- `WHERE` 제목 LIKE '%Love%'
  - OR 제목 LIKE '%love%'
- `ORDER BY` 로튼 토마토 평점 DESC, 개봉 연도 DESC;

  <br>

## ⌨️ **제출 SQL**

```sql
SELECT
  title,
  year,
  rotten_tomatoes
FROM
  movies
WHERE
  title LIKE '%Love%'
  OR title LIKE '%love%'
ORDER BY
  rotten_tomatoes DESC,
  year DESC;


```

<br>

## 💡 **풀이 포인트**

- 문자열 포함 여부는 `LIKE '%문자열%'` 패턴으로 검색

- `ORDER BY`에는 여러 컬럼을 지정할 수 있으며, 앞선 정렬 기준의 값이 같을 때 다음 컬럼을 기준으로 정렬


<br>

<!--
## 🧩 **관련 개념**


<!--
<br>
-->

<!--
## 🔗 **참고**


<br>
 -->