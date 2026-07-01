---
title: "🌸 [solvesql] DVD 대여점 우수 고객 찾기 (MySQL)"
date: 2026-07-01 14:16:19 +09:00
categories: [sql, solvesql]
tags:
  [sql, solvesql, solvesql level 2, mysql]
description: "solvesql 'DVD 대여점 우수 고객 찾기' MySQL 풀이"
---

  <br>


<center><a href="https://solvesql.com/problems/dvdrental-vip/" style = 'font-size : 1.18rem; font-weight : 900'>👉 solvesql - DVD 대여점 우수 고객 찾기</a></center>

  <br>

## 📌 **문제 요약**

현재 유효 고객 중 DVD 대여 횟수가 35회 이상인 우수 고객의 ID를 조회하는 문제이다.

- 조건
  - 현재 유효 고객만 조회 대상에 포함한다.
  - 고객별 DVD 대여 횟수를 집계한다.
  - 대여 횟수가 `35회` 이상인 고객만 조회한다.
  - 결과에는 고객 ID(`customer_id`)만 출력한다.

  <br>

## ✅ **풀이**

- `SELECT` 고객 id
- `FROM` 고객 테이블, 대여 정보 테이블 join
- `WHERE` 유효 고객
- `GROUP BY` 고객 id
- `HAVING` 대여 횟수 35회 이상;

  🔽

- `SELECT` 고객 id
- `FROM` rental JOIN customer ON customer_id
- `WHERE` 유효고객여부 = true
- `GROUP BY` 고객 id
- `HAVING` COUNT(대여 id) >= 35;

  <br>

## ⌨️ **SQL 쿼리**

```sql
SELECT
  c.customer_id
FROM
  rental r
  JOIN customer c 
  ON r.customer_id = c.customer_id
WHERE
  c.active = true
GROUP BY
  c.customer_id
HAVING
  COUNT(r.rental_id) >= 35;

```

<br>

## 💡 **풀이 포인트**

- `JOIN`을 사용하면 여러 테이블을 연결하여 필요한 데이터를 함께 조회할 수 있다.
- `WHERE` 절은 그룹화 이전에 행을 필터링하므로, 유효 고객만 대상으로 집계를 수행할 수 있다.
- `GROUP BY`를 사용하여 고객별로 대여 내역을 묶은 후 집계할 수 있다.
- `COUNT(컬럼)`은 `NULL`을 제외한 값의 개수를 계산하며, 특정 컬럼의 개수를 집계할 때 사용한다.
- 집계 결과에 조건을 적용할 때는 `HAVING` 절을 사용한다.

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