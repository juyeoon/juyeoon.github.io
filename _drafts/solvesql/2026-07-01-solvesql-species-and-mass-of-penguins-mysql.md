---
title: "🌸 [solvesql] 펭귄의 종과 몸무게 조회하기 (MySQL)"
date: 2026-07-01 08:57:39 +09:00
categories: [sql, solvesql]
tags:
  [sql, solvesql, solvesql level 1, mysql]
description: "solvesql '펭귄의 종과 몸무게 조회하기' MySQL 풀이"
---

  <br>


<center><a href="https://solvesql.com/problems/species-and-mass-of-penguins/" style = 'font-size : 1.18rem; font-weight : 900'>👉 solvesql - 펭귄의 종과 몸무게 조회하기</a></center>

  <br>

## 📌 **문제 요약**

펭귄의 종과 몸무게 정보를 조회하여 몸무게와 종의 관계를 분석하기 위한 기초 데이터를 추출하는 문제이다.

- 조건
  - 펭귄의 종(`species`)과 몸무게(`body_mass_g`)를 조회한다.
  - 종 또는 몸무게 정보가 없는 개체는 제외한다.
  - 몸무게를 기준으로 내림차순 정렬한다.
  - 몸무게가 같으면 종 이름을 기준으로 오름차순 정렬한다.
  
  <br>

## ✅ **풀이**

- `SELECT` 종, 몸무게
- `FROM` penguins
- `WHERE` 종이 없지 않음 AND 몸무게가 없지 않음
- `ORDER BY` 몸무게 역순, 종;

  🔽

- `SELECT` 종, 몸무게
- `FROM` penguins
- `WHERE` 종 IS NOT NULL AND 몸무게 IS NOT NULL
- `ORDER BY` 몸무게 DESC, 종 ASC;

  <br>

## ⌨️ **제출 SQL**

```sql
SELECT
  species,
  body_mass_g
FROM
  penguins
WHERE
  species IS NOT NULL
  AND body_mass_g IS NOT NULL
ORDER BY
  body_mass_g DESC,
  species ASC;

```

<br>

## 💡 **풀이 포인트**

- `NULL` 값은 일반적인 비교 연산자로 비교할 수 없으므로, 값의 존재 여부를 확인할 때는 `IS NOT NULL`을 사용해야 한다.
- `WHERE` 절에서 `IS NOT NULL` 조건을 사용하면 필요한 데이터가 없는 행을 제외하고 조회할 수 있다.
- `ORDER BY`에는 여러 정렬 기준을 지정할 수 있으며, 앞선 기준의 값이 같을 경우 다음 컬럼을 기준으로 정렬한다.
- `ORDER BY`는 컬럼마다 `ASC`(오름차순)와 `DESC`(내림차순)를 각각 지정할 수 있다.
  
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