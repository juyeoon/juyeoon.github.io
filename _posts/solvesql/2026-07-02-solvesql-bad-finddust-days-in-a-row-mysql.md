---
title: "🌸 [solvesql] 이틀 연속 미세먼지가 나빠진 날 (MySQL)"
date: 2026-07-02 14:47:33 +09:00
categories: [sql, solvesql]
tags:
  [sql, solvesql, solvesql level 2, mysql]
description: "solvesql '이틀 연속 미세먼지가 나빠진 날' MySQL 풀이"
---

  <br>


<center><a href="https://solvesql.com/problems/bad-finddust-days-in-a-row/" style = 'font-size : 1.18rem; font-weight : 900'>👉 solvesql - 이틀 연속 미세먼지가 나빠진 날</a></center>

  <br>

## 📌 **문제 요약**

2022년 대기 측정 데이터에서 미세먼지(PM10) 농도가 이틀 연속 증가하여 30㎍/㎥ 이상이 된 날짜를 조회하는 문제이다.

- 조건
  - 3일 연속 측정 데이터가 존재해야 한다.
  - 미세먼지 농도가 전날보다 증가하고, 그 전날도 이전 날보다 증가해야 한다.
  - 조회 대상 날짜의 미세먼지 농도는 `30㎍/㎥` 이상이어야 한다.
  - 결과 컬럼명은 `date_alert`로 지정한다.
  - 날짜를 기준으로 오름차순 정렬한다.

  <br>

## ✅ **풀이**

- `SELECT` 오늘 날짜
- `FROM` 오늘 날짜 기준 어제 날짜 기준 그제 날짜
- `WHERE` 그제 미세먼지 < 어제 미세먼지 < 오늘 미세먼지 AND 오늘 미세먼지 30 이상;

  🔽

- `SELECT` 오늘 날짜
- `FROM` 오늘 JOIN 어제 ON 오늘 날짜 = 어제 날짜 + 1일 JOIN 그제 ON 어제 날짜 = 그제 날짜 + 1
- `WHERE` 그제 미세먼지 < 어제 미세먼지 AND 어제 미세먼지 < 오늘 미세먼지 AND 오늘 미세먼지 >= 30;

  <br>

## ⌨️ **SQL 쿼리**

```sql
SELECT
  curr.measured_at AS date_alert
FROM
  measurements curr 
  JOIN measurements prev
    ON curr.measured_at = DATE_ADD(prev.measured_at, INTERVAL 1 DAY)
  JOIN measurements prev2 
    ON prev.measured_at = DATE_ADD(prev2.measured_at, INTERVAL 1 DAY)
WHERE
  prev2.pm10 < prev.pm10
  AND prev.pm10 < curr.pm10
  AND curr.pm10 >= 30;

```

<br>

## 💡 **풀이 포인트**

- 같은 테이블을 여러 번 조회해야 하는 경우 **Self Join**을 사용하여 하나의 테이블을 여러 역할로 나누어 사용할 수 있다.
- Self Join 시에는 `curr`, `prev`, `prev2`와 같이 테이블 별칭을 부여하면 각 행의 역할을 구분하기 쉽다.
- `DATE_ADD()`를 사용하면 날짜에 일정 기간을 더하거나 빼서 연속된 날짜의 데이터를 연결할 수 있다.
- `WHERE` 절에서 이전 날짜와 현재 날짜의 값을 비교하여 미세먼지 농도가 이틀 연속 증가하는 조건을 표현할 수 있다.
- 여러 조건은 `AND`를 사용하여 모두 만족하는 데이터만 조회할 수 있다.
- MySQL 8.0 이상에서는 윈도우 함수인 `LAG()`를 사용하여 이전 행의 값을 조회하는 방식으로도 해결할 수 있다.
  - 다만 `LAG()`는 **정렬된 이전 행**을 기준으로 값을 가져오기 때문에, 날짜가 연속되어 있다는 보장이 없는 경우에는 실제 연속된 날짜를 확인할 수 없다. 이러한 경우에는 `DATE_ADD()`를 이용한 Self Join 방식이 더 적합하다.
  
<br>

<!--
## 🧩 **관련 개념**


<br>
-->

<!--
## 🔗 **참고**


<br>
 -->

> 📚 **더 많은 solvesql 풀이**
> 
> > 👉 [solvesql 풀이 전체 보기](/categories/solvesql/)