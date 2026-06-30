---
title: "🌸 [solvesql] 서울숲에 놀러 가기 좋은 날 (MySQL)"
date: 2026-06-30 16:31:26 +09:00
categories: [sql, solvesql]
tags:
  [sql, solvesql, solvesql level 1, mysql]
description: "solvesql '서울숲에 놀러 가기 좋은 날' MySQL 풀이"
---

  <br>


<center><a href="https://solvesql.com/problems/good-days-for-a-seoulforest-picnic/" style = 'font-size : 1.18rem; font-weight : 900'>👉 solvesql - 서울숲에 놀러 가기 좋은 날</a></center>

  <br>

## 📌 **문제 요약**

2022년 12월 중 서울숲의 초미세먼지(PM2.5) 농도가 야외 활동 기준을 만족하는 날짜를 조회하는 문제이다.

- 조건
  - 조회 대상은 2022년 12월 데이터이다.
  - 초미세먼지(PM2.5) 농도가 `9㎍/㎥` 이하인 날짜만 조회한다.
  - 결과 컬럼명은 `good_day`로 지정한다.
  - 날짜를 오름차순으로 정렬한다.

  <br>

## ✅ **풀이**

- `SELECT` 측정 날짜 AS good_day
- `FROM` measurements
- `WHERE` 초미세먼지 농도 <= 9
  - AND 2022년 12월 측정
- `ORDER BY` 측정 날짜;

  🔽

- `SELECT` 측정 날짜 AS good_day
- `FROM` measurements
- `WHERE` 초미세먼지 농도 <= 9
  - AND 측정 날짜 >= 2022년 12월 1일
  - AND 측정 날짜 < 2023년 1월 1일;
- `ORDER BY` 측정 날짜;

  <br>

## ⌨️ **제출 SQL**

```sql
SELECT
  measured_at AS good_day
FROM
  measurements
WHERE
  pm2_5 <= 9
  AND measured_at >= '2022-12-01'
  AND measured_at < '2023-01-01'
ORDER BY
  measured_at;

```

<br>

## 💡 **풀이 포인트**

- 날짜 범위를 조회할 때는 `>= 시작일`과 `< 다음 기간의 시작일` 형태를 사용하면 기간의 시작은 포함하고 끝은 제외하여 정확한 범위를 조회할 수 있다.
- `AS`를 사용하면 조회 결과의 컬럼명을 원하는 이름으로 변경할 수 있다.
- `ORDER BY`를 사용하면 조회 결과를 원하는 기준으로 정렬할 수 있으며, 오름차순은 `ASC`를 생략해도 동일하게 동작한다.

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