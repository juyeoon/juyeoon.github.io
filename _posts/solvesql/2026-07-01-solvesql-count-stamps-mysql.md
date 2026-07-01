---
title: "🌸 [solvesql] 스탬프를 찍어드려요 (MySQL)"
date: 2026-07-01 10:26:24 +09:00
categories: [sql, solvesql]
tags:
  [sql, solvesql, solvesql level 2, mysql]
description: "solvesql '스탬프를 찍어드려요' MySQL 풀이"
---

  <br>


<center><a href="https://solvesql.com/problems/count-stamps/" style = 'font-size : 1.18rem; font-weight : 900'>👉 solvesql - 스탬프를 찍어드려요</a></center>

  <br>

## 📌 **문제 요약**

영수증 금액에 따라 지급되는 스탬프 개수를 계산한 후, 스탬프 개수별 영수증 수를 집계하는 문제이다.

- 조건
  - 영수 금액이 `25달러` 이상이면 스탬프 `2개`를 지급한다.
  - 영수 금액이 `15달러` 이상 `25달러` 미만이면 스탬프 `1개`를 지급한다.
  - 영수 금액이 `15달러` 미만이면 스탬프를 지급하지 않는다.
  - 스탬프 개수별 영수증 개수를 집계한다.
  - 결과 컬럼명은 `stamp`, `count_bill`로 지정한다.
  - 스탬프 개수를 기준으로 오름차순 정렬한다.

  <br>

## ✅ **풀이**

- `SELECT` 영수 금액에 따른 스탬프 개수, 스탬프별 개수
- `FROM` tips
- `GROUP BY` 스탬프 개수
- `ORDER BY` 스탬프 개수;

  🔽

- `SELECT` 
  - CASE 
    - WHEN 영수 금액 < 15 THEN 0
    - WHEN 영수 금액 < 25 THEN 1
    - ELSE 2
  - END AS stamp,
  - COUNT(*) AS count_bill
- `FROM` tips
- `GROUP BY` stamp
- `ORDER BY` stamp;

  <br>

## ⌨️ **SQL 쿼리**

```sql
SELECT
  CASE
    WHEN total_bill < 15 THEN 0
    WHEN total_bill < 25 THEN 1
    ELSE 2
  END AS stamp,
  COUNT(*) AS count_bill
FROM
  tips
GROUP BY
  stamp
ORDER BY
  stamp;

```

<br>

## 💡 **풀이 포인트**

- `CASE` 문을 사용하면 조건에 따라 서로 다른 값을 반환할 수 있으며, 조회 결과에 새로운 값을 생성할 때 자주 사용된다.
- `CASE` 문은 조건을 위에서부터 순차적으로 검사하므로, 범위 조건을 작성할 때는 조건의 순서를 고려해야 한다.
- `GROUP BY`에는 `CASE` 문의 결과를 사용하여 동일한 스탬프 개수를 가진 데이터를 하나의 그룹으로 묶을 수 있다.
- `COUNT(*)`는 각 그룹에 포함된 행의 개수를 집계할 때 사용한다.
- `ORDER BY`를 사용하면 집계 결과를 원하는 기준으로 정렬할 수 있다.
- MySQL에서는 `SELECT` 절에서 정의한 별칭(`stamp`)을 `GROUP BY`에서 사용할 수 있다.
  - 하지만 일부 DBMS에서는 `GROUP BY`에서 `SELECT` 별칭을 바로 사용할 수 없기 때문에, `CASE` 문을 `GROUP BY`에 다시 작성하거나 CTE/서브쿼리로 먼저 계산한 뒤 집계해야 한다.
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

> 📚 **더 많은 solvesql 풀이**
> 
> > 👉 [solvesql 풀이 전체 보기](/categories/solvesql/)