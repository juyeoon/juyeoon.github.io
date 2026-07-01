---
title: "🌸 [solvesql] 12월 우수 고객 찾기 (MySQL)"
date: 2026-07-01 10:01:20 +09:00
categories: [sql, solvesql]
tags:
  [sql, solvesql, solvesql level 2, mysql]
description: "solvesql '12월 우수 고객 찾기' MySQL 풀이"
---

  <br>


<center><a href="https://solvesql.com/problems/whales-of-december/" style = 'font-size : 1.18rem; font-weight : 900'>👉 solvesql - 12월 우수 고객 찾기</a></center>

  <br>

## 📌 **문제 요약**

2020년 12월 동안 발생한 주문의 총매출이 1000달러 이상인 고객의 ID를 조회하는 문제이다.

- 조건
  - 조회 대상은 2020년 12월 주문 데이터이다.
  - 고객별 주문 금액을 합산하여 총매출을 계산한다.
  - 총매출이 `1000$` 이상인 고객만 조회한다.
  - 결과에는 고객 ID 컬럼만 출력한다.

  <br>

## ✅ **풀이**

- `SELECT` 고객 id
- `FROM` records
- `WHERE` 주문 날짜가 12월
- `GROUP BY` 고객 id
- `HAVING` 주문 매출액의 총 합이 1000 이상;

  🔽

- `SELECT` 고객 id
- `FROM` records
- `WHERE` MONTH(주문 날짜) = 12
- `GROUP BY` 고객 id
- `HAVING` SUM(주문 매출액) >= 1000;

  <br>

## ⌨️ **제출 SQL**

```sql
SELECT
  customer_id
FROM
  records
WHERE
  MONTH(order_date) = 12
GROUP BY
  customer_id
HAVING
  SUM(sales) >= 1000;

```

<br>

## 💡 **풀이 포인트**

- `GROUP BY`를 사용하면 고객별로 주문 데이터를 묶어 집계할 수 있다.
- `SUM()` 함수는 그룹별 매출 합계를 계산할 때 사용한다.
- 집계 함수 결과를 조건으로 필터링할 때는 `WHERE`가 아니라 `HAVING`을 사용해야 한다.
- `WHERE`는 그룹화되기 전 개별 행을 필터링하고, `HAVING`은 `GROUP BY` 이후 생성된 그룹을 필터링한다.
- `MONTH()` 함수를 사용하면 날짜 컬럼에서 월 정보만 추출하여 특정 월의 데이터만 조회할 수 있다.
  - 연도가 섞일 수 있는 데이터라면 `order_date >= '2020-12-01' AND order_date < '2021-01-01'` 방식이 더 정확

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