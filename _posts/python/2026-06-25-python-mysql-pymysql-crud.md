---
title: "Python MySQL 연동 (PyMySQL CRUD)"
date: 2026-06-25 09:25:31 +09:00
categories: [python, database]
tags: [python, pymysql, mysql, crud, sql injection]
---

👉 PyMySQL을 이용하여 Python과 MySQL을 연동하는 방법을 정리한다. Connection과 Cursor의 역할부터 CRUD 구현, 트랜잭션 처리, 파라미터 바인딩, SQL Injection 방지까지 함께 살펴본다.

<br/>

## 🎯 학습 목표

Python 프로그램에서 MySQL 데이터베이스를 사용하는 방법을 정리한다.

PyMySQL 라이브러리를 이용하여 데이터베이스에 연결하고, SQL을 실행하여 데이터를 조회(Read), 삽입(Create), 수정(Update), 삭제(Delete)하는 기본적인 CRUD 작업을 구현해본다.

또한 트랜잭션 처리와 파라미터 바인딩을 함께 살펴보며, 데이터베이스를 안전하게 사용하는 기본적인 방법도 함께 익혀본다.

이번 포스팅에서 다루는 내용은 다음과 같다.

- **PyMySQL**을 이용한 **MySQL 연결**
- **Connection**과 **Cursor**의 역할
- **CRUD 구현 방법**
- `commit()`과 `rollback()`을 이용한 **트랜잭션 처리**
- **SQL Injection**을 방지하는 **파라미터 바인딩**

<br/>

## 🛠️ 사전 준비

Python에서 MySQL을 사용하기 위해서는 데이터베이스에 접근할 수 있는 라이브러리와 테스트를 위한 데이터베이스 환경이 준비되어 있어야 한다.

이번 포스팅에서는 `PyMySQL` 라이브러리를 사용하며, 예제는 로컬 환경에서 실행되는 MySQL을 기준으로 진행한다.

### PyMySQL 설치

`pip` 명령어를 이용하여 PyMySQL을 설치한다.

```bash
pip install pymysql
```

설치가 완료되면 Python에서 다음과 같이 라이브러리를 불러올 수 있다.

```python
import pymysql
```

### 실습 환경

예제를 실행하기 위해서는 MySQL 서버가 실행 중이어야 하며, 사용할 데이터베이스와 테이블이 미리 생성되어 있어야 한다.

이번 예제에서는 다음과 같은 `emp` 테이블을 기준으로 CRUD를 구현한다.

| 컬럼명     | 데이터 타입     | 설명                   |
| ---------- | --------------- | ---------------------- |
| `empno`    | `INT`           | 사원번호 (Primary Key) |
| `ename`    | `VARCHAR(20)`   | 사원명                 |
| `job`      | `VARCHAR(20)`   | 직급                   |
| `hiredate` | `DATE`          | 입사일                 |
| `sal`      | `DECIMAL(10,2)` | 급여                   |
| `deptno`   | `INT`           | 부서번호               |

- 샘플 데이터 준비

  ```sql
  CREATE DATABASE IF NOT EXISTS company;
  USE company;

  CREATE TABLE emp (
      empno INT PRIMARY KEY COMMENT '사원번호',
      ename VARCHAR(20) NOT NULL COMMENT '사원명',
      job VARCHAR(20) COMMENT '직급',
      hiredate DATE COMMENT '입사일',
      sal DECIMAL(10,2) COMMENT '급여',
      deptno INT COMMENT '부서번호'
  );

  INSERT INTO emp (empno, ename, job, hiredate, sal, deptno) VALUES
  (1001, 'KIM',    'DEVELOPER', '2022-03-01', 3800000, 10),
  (1002, 'LEE',    'DEVELOPER', '2021-07-15', 4200000, 10),
  (1003, 'PARK',   'MANAGER',   '2019-05-20', 5500000, 10),
  (1004, 'CHOI',   'ANALYST',   '2023-01-10', 3600000, 20),
  (1005, 'JUNG',   'DEVELOPER', '2022-09-05', 4100000, 20),
  (1006, 'HAN',    'MANAGER',   '2018-11-01', 6200000, 20),
  (1007, 'YOON',   'SALESMAN',  '2021-12-20', 3300000, 30),
  (1008, 'LIM',    'SALESMAN',  '2020-08-18', 3500000, 30),
  (1009, 'KANG',   'ANALYST',   '2019-04-12', 4700000, 30),
  (1010, 'SHIN',   'DIRECTOR',  '2017-02-01', 7800000, 40);
  ```

이번 포스팅에서 사용하는 환경은 다음과 같다.

| 항목     | 내용       |
| -------- | ---------- |
| Language | Python 3.x |
| Database | MySQL 8.x  |

<br/>

## 🔗 PyMySQL 기본 개념

PyMySQL은 Python에서 MySQL 데이터베이스와 통신하기 위한 라이브러리이다.

Python이 직접 MySQL 서버와 통신하는 것이 아니라, **PyMySQL이 SQL을 전달하고 실행 결과를 Python 객체 형태로 변환하여 반환하는 역할을 수행한다.**

따라서 데이터베이스 작업은 단순히 SQL을 실행하는 것에서 끝나는 것이 아니라, **Connection을 생성하여 데이터베이스에 연결하고, Cursor를 통해 SQL을 실행한 뒤, 필요한 경우 트랜잭션을 처리하고 연결을 종료하는 순서로 이루어진다.**

이러한 기본 동작 과정을 이해하면 이후에 다룰 CRUD 구현과 예외 처리도 더욱 쉽게 이해할 수 있다.

### 📙 Connection 객체 : 데이터베이스 연결

Connection 객체는 Python 프로그램과 MySQL 서버를 연결하는 역할을 한다.

데이터베이스에 접근하기 위해 가장 먼저 생성해야 하는 객체이며, 접속 정보(호스트, 사용자, 비밀번호, 데이터베이스명 등)를 이용하여 생성한다.

```python
import pymysql

conn = pymysql.connect(
    host="DB_HOST",          # 데이터베이스 서버 주소
    user="DB_USER",          # 사용자 계정
    password="DB_PASSWORD",  # 비밀번호
    database="DB_NAME",      # 사용할 데이터베이스
    charset="utf8mb4"        # 문자 인코딩
)
```

Connection이 생성되면 데이터베이스와 통신할 준비가 완료된다.

### 📙 Cursor 객체 : SQL 실행

Connection 객체는 데이터베이스 연결을 관리하며, SQL 실행은 Cursor 객체를 통해 수행한다.

```python
cursor = conn.cursor()
```

Cursor는 SQL을 데이터베이스에 전달하고, 실행 결과를 Python으로 가져오는 역할을 수행한다.

### 📙 SQL 실행 과정

PyMySQL을 이용한 데이터베이스 작업은 대부분 아래와 같은 순서로 진행된다.

```
1. Connection 생성
        ↓
2. Cursor 생성
        ↓
3. SQL 실행 (execute)
        ↓
4. 결과 조회 (fetch)
        ↓
5. 트랜잭션 처리 (commit / rollback)
        ↓
6. Cursor 종료
        ↓
7. Connection 종료
```

조회(SELECT)는 결과를 가져오는 과정이 추가되고, 삽입·수정·삭제(INSERT/UPDATE/DELETE)는 트랜잭션 처리가 필요하다.

### 📙 `execute()` : SQL 실행

SQL을 실행할 때는 `execute()` 메서드를 사용한다.

```python
sql = "SELECT * FROM emp"

cursor.execute(sql)
```

SQL문에 값을 전달할 때는 문자열을 직접 연결하지 않고 파라미터 바인딩을 사용하는 것이 좋다.

```python
sql = "SELECT * FROM emp WHERE deptno = %s"

cursor.execute(sql, (10,))
```

`%s`는 전달할 값을 의미하며, `execute()`의 두 번째 인자는 **튜플(tuple) 또는 리스트(list)** 형태로 전달한다.

> **참고:** 값이 하나인 경우에도 `(10,)`과 같이 튜플 형태로 작성해야 한다.

### 📙 `fetch()` 메서드 : 조회 결과 가져오기

조회 결과는 필요에 따라 여러 가지 메서드로 가져올 수 있다.

| 메서드         | 설명                 |
| -------------- | -------------------- |
| `fetchone()`   | 한 개의 행 반환      |
| `fetchmany(n)` | 지정한 개수만큼 반환 |
| `fetchall()`   | 모든 행 반환         |

예를 들어 전체 데이터를 조회하려면 다음과 같이 사용할 수 있다.

```python
cursor.execute("SELECT * FROM emp")

rows = cursor.fetchall()

for row in rows:
    print(row)
```

### 📙 `commit()`과 `rollback()` : 트랜잭션 처리

PyMySQL은 기본적으로 autocommit이 비활성화되어 있으므로 INSERT, UPDATE, DELETE 이후에는 commit()을 호출해야 변경 사항이 데이터베이스에 반영된다.

변경 내용을 실제 데이터베이스에 반영하려면 `commit()`을 호출해야 한다.

```python
conn.commit()
```

작업 도중 오류가 발생했다면 `rollback()`으로 이전 상태로 되돌릴 수 있다.

```python
conn.rollback()
```

트랜잭션 처리를 통해 데이터의 일관성을 유지할 수 있으며, 실무에서도 반드시 사용되는 기능이다.

### 📙 `close()` : 연결 종료

사용이 끝난 Connection과 Cursor는 반드시 종료하는 것이 좋다.

```python
cursor.close()
conn.close()
```

사용하지 않는 객체를 계속 유지하면 불필요하게 데이터베이스 연결이 점유될 수 있으므로, 작업이 끝난 후에는 항상 종료하는 습관을 들이는 것이 좋다.

<br/>

## 🧩 DB 연결

앞으로 작성할 CRUD 함수에서는 모두 동일한 데이터베이스에 접속해야 한다.

매번 `pymysql.connect()`를 반복해서 작성하는 대신, 데이터베이스 연결을 반환하는 함수를 하나 만들어두면 코드의 중복을 줄일 수 있다.

### 🔖 DB 연결 함수

```python
import pymysql

def get_connection():
    return pymysql.connect(
        host="host",          # 데이터베이스 서버 주소
        user="user",          # 사용자 계정
        password="password",  # 사용자 비밀번호
        database="company",   # 연결할 데이터베이스 이름
        charset="utf8mb4"     # 문자 인코딩
    )
```

`get_connection()`을 호출하면 `Connection` 객체가 반환되며, 이후 CRUD 함수에서는 이 객체를 이용하여 데이터베이스 작업을 수행한다.

### 🔖 Connection과 Cursor 생성

데이터베이스 작업을 시작할 때는 먼저 `Connection`을 생성하고, 그 다음 `Cursor`를 생성한다.

```python
conn = get_connection()
cursor = conn.cursor()
```

- `Connection` : 데이터베이스와 연결을 관리하는 객체
- `Cursor` : SQL을 실행하고 결과를 가져오는 객체

이 두 객체는 대부분의 데이터베이스 작업에서 항상 함께 사용된다.

### 🔖 CRUD에서의 공통 구조

앞으로 작성할 모든 함수는 다음과 같은 구조를 사용한다.

```python
def function_name():

    conn = get_connection()
    cursor = conn.cursor()

    try:
        # SQL 실행

    finally:
        cursor.close()
        conn.close()
```

조회뿐만 아니라 삽입, 수정, 삭제 역시 같은 흐름으로 작성할 수 있으며, `finally`에서 `Cursor`와 `Connection`을 종료하면 예외가 발생하더라도 연결이 정상적으로 정리된다.

<br/>

## 📖 READ (조회)

PyMySQL에서는 `SELECT` 문을 실행한 후 `fetchone()`, `fetchmany()`, `fetchall()` 메서드를 이용하여 조회 결과를 가져올 수 있다.

### 🔖 기본 작성 포맷

PyMySQL을 사용한 조회 함수는 보통 다음 흐름으로 작성한다.

```python
def 함수명():
    conn = get_connection()
    cursor = conn.cursor()

    try:
        sql = """
            SELECT 컬럼명
            FROM 테이블명
            WHERE 조건
        """

        cursor.execute(sql, 값)

        rows = cursor.fetchall()

        for row in rows:
            print(row)

    finally:
        cursor.close()
        conn.close()
```

`SELECT`는 데이터를 변경하지 않으므로 `commit()`이 필요하지 않다.

### ⌨️ 예제: 전체 사원 조회

`emp` 테이블의 모든 사원을 조회하는 함수이다.

```python
def select_all_emp():
    conn = get_connection()
    cursor = conn.cursor()

    try:
        sql = """
            SELECT empno, ename, job, hiredate, sal, deptno
            FROM emp
            ORDER BY empno
        """

        cursor.execute(sql)

        rows = cursor.fetchall()

        for row in rows:
            print(row)

    finally:
        cursor.close()
        conn.close()
```

- ► 사용 예시와 실행 결과
  ```python
  select_all_emp()
  ```
  ```
  (1001, 'KIM', 'DEVELOPER', datetime.date(2022, 3, 1), Decimal('3800000.00'), 10)
  (1002, 'LEE', 'DEVELOPER', datetime.date(2021, 7, 15), Decimal('4200000.00'), 10)
  (1003, 'PARK', 'MANAGER', datetime.date(2019, 5, 20), Decimal('5500000.00'), 10)
  (1004, 'CHOI', 'ANALYST', datetime.date(2023, 1, 10), Decimal('3600000.00'), 20)
  (1005, 'JUNG', 'DEVELOPER', datetime.date(2022, 9, 5), Decimal('4100000.00'), 20)
  (1006, 'HAN', 'MANAGER', datetime.date(2018, 11, 1), Decimal('6200000.00'), 20)
  (1007, 'YOON', 'SALESMAN', datetime.date(2021, 12, 20), Decimal('3300000.00'), 30)
  (1008, 'LIM', 'SALESMAN', datetime.date(2020, 8, 18), Decimal('3500000.00'), 30)
  (1009, 'KANG', 'ANALYST', datetime.date(2019, 4, 12), Decimal('4700000.00'), 30)
  (1010, 'SHIN', 'DIRECTOR', datetime.date(2017, 2, 1), Decimal('7800000.00'), 40)
  ```

### ⌨️ 예제: 조건 조회

특정 부서의 사원만 조회하려면 `WHERE` 절을 사용한다.

```python
def select_emp_by_deptno(deptno):
    conn = get_connection()
    cursor = conn.cursor()

    try:
        sql = """
            SELECT empno, ename, job, hiredate, sal, deptno
            FROM emp
            WHERE deptno = %s
            ORDER BY empno
        """

        cursor.execute(sql, (deptno,))

        rows = cursor.fetchall()

        for row in rows:
            print(row)

    finally:
        cursor.close()
        conn.close()
```

- ► 사용 예시와 실행 결과
  ```python
  select_emp_by_deptno(10)
  ```
  ```
  (1001, 'KIM', 'DEVELOPER', datetime.date(2022, 3, 1), Decimal('3800000.00'), 10)
  (1002, 'LEE', 'DEVELOPER', datetime.date(2021, 7, 15), Decimal('4200000.00'), 10)
  (1003, 'PARK', 'MANAGER', datetime.date(2019, 5, 20), Decimal('5500000.00'), 10)
  ```

### 📙 파라미터 바인딩

PyMySQL에서는 SQL 안에 값을 직접 작성하지 않고 `%s`를 사용하여 값을 전달한다.

`%s`는 SQL 안에 값을 직접 넣는 자리가 아니라, PyMySQL이 값을 안전하게 전달하기 위한 **자리 표시자(Placeholder)**이다.

```python
sql = """
SELECT empno, ename, job, hiredate, sal, deptno
FROM emp
WHERE deptno = %s
ORDER BY empno
"""

cursor.execute(sql, (deptno,))
```

`execute()`의 두 번째 인자는 튜플(tuple) 또는 리스트(list) 형태로 전달해야 한다.

값이 하나만 있어도 `(deptno)`가 아니라 `(deptno,)`처럼 쉼표를 붙여 튜플로 만들어야 한다.

PyMySQL에서는 데이터 타입과 관계없이 모든 파라미터 자리에 `%s`를 사용한다. 문자열뿐 아니라 숫자, 날짜 등의 값도 모두 `%s`로 전달하며, 실제 데이터 타입에 맞는 처리는 PyMySQL이 자동으로 수행한다.

이처럼 SQL과 데이터를 분리하여 전달하면 SQL 문이 더 읽기 쉬워지고, 입력값이 SQL 문법으로 해석되지 않으므로 SQL Injection을 예방할 수 있다.

### ⌨️ 예제: 단일 사원 조회

조회 결과가 한 건만 필요하다면 `fetchone()`을 사용할 수 있다.

조건에 맞는 데이터가 없으면 `None`을 반환한다.

```python
def select_emp_by_empno(empno):
    conn = get_connection()
    cursor = conn.cursor()

    try:
        sql = """
            SELECT empno, ename, job, hiredate, sal, deptno
            FROM emp
            WHERE empno = %s
        """

        cursor.execute(sql, (empno,))

        row = cursor.fetchone()

        print(row)

    finally:
        cursor.close()
        conn.close()
```

- ► 사용 예시와 실행 결과
  ```python
  select_emp_by_empno(1001)
  ```
  ```
  (1001, 'KIM', 'DEVELOPER', datetime.date(...), Decimal(...), 10)
  ```

### 📙 조회 결과를 가져오는 메서드

| 메서드         | 설명                           |
| -------------- | ------------------------------ |
| `fetchone()`   | 조회 결과 중 한 행만 가져온다  |
| `fetchmany(n)` | 조회 결과 중 n개 행을 가져온다 |
| `fetchall()`   | 조회 결과 전체를 가져온다      |

전체 목록을 출력할 때는 `fetchall()`을 사용하고, 사원번호처럼 하나의 행만 조회할 때는 `fetchone()`을 사용하는 것이 자연스럽다.

<br/>

## ➕ CREATE (삽입)

데이터를 추가할 때, SQL에서는 `INSERT` 문을 사용한다.

조회와 달리 데이터를 변경하는 작업이므로, SQL 실행 후 반드시 **트랜잭션을 처리해야 한다.**

### 🔖 기본 작성 포맷

PyMySQL을 사용한 삽입 함수는 일반적으로 다음과 같은 구조로 작성한다.

```python
def 함수명():
    conn = get_connection()
    cursor = conn.cursor()

    try:
        sql = """
            INSERT INTO 테이블명 (컬럼1, 컬럼2, ...)
            VALUES (%s, %s, ...)
        """

        cursor.execute(sql, 값)

        conn.commit()

    except Exception:
        conn.rollback()

    finally:
        cursor.close()
        conn.close()
```

### ⌨️ 예제: 사원 등록

새로운 사원 정보를 `emp` 테이블에 추가하는 함수이다.

```python
def insert_emp(empno, ename, job, hiredate, sal, deptno):
    conn = get_connection()
    cursor = conn.cursor()

    try:
        sql = """
            INSERT INTO emp (
                empno,
                ename,
                job,
                hiredate,
                sal,
                deptno
            )
            VALUES (%s, %s, %s, %s, %s, %s)
        """

        cursor.execute(
            sql,
            (empno, ename, job, hiredate, sal, deptno)
        )

        conn.commit()

        print("사원 등록이 완료되었습니다.")

    except Exception as e:
        conn.rollback()
        print(f"오류 발생 : {e}")

    finally:
        cursor.close()
        conn.close()
```

- ► 사용 예시와 실행 결과
  ```python
  insert_emp(
      1011,
      "SONG",
      "DEVELOPER",
      "2024-01-15",
      3900000,
      20
  )
  ```
  ```
  사원 등록이 완료되었습니다.
  ```

### 📘 `try`-`except`-`finally`를 사용하는 이유

데이터를 변경하는 작업에서는 예외 처리가 필수적이다.

```python
try:
    cursor.execute(sql, values)
    conn.commit()

except Exception:
    conn.rollback()

finally:
    cursor.close()
    conn.close()
```

이 구조를 사용하면 예외가 발생하더라도 데이터의 일관성을 유지하고, 사용한 자원을 안전하게 정리할 수 있다.

<br/>

## ✏️ UPDATE (수정)

데이터를 수정할 때, SQL에서는 `UPDATE` 문을 사용한다.

데이터를 변경하는 작업이므로 `INSERT`와 마찬가지로 **트랜잭션(commit / rollback)** 처리가 필요하다.

### 🔖 기본 작성 포맷

PyMySQL을 사용한 수정 함수는 일반적으로 다음과 같은 구조로 작성한다.

```python
def 함수명():
    conn = get_connection()
    cursor = conn.cursor()

    try:
        sql = """
            UPDATE 테이블명
            SET 컬럼명 = %s
            WHERE 조건
        """

        cursor.execute(sql, 값)

        conn.commit()

    except Exception:
        conn.rollback()

    finally:
        cursor.close()
        conn.close()
```

### ⌨️ 예제: 사원 급여 수정

사원번호를 기준으로 급여를 수정하는 함수이다.

```python
def update_emp_sal(empno, sal):
    conn = get_connection()
    cursor = conn.cursor()

    try:
        sql = """
            UPDATE emp
            SET sal = %s
            WHERE empno = %s
        """

        cursor.execute(sql, (sal, empno))

        conn.commit()

        print("사원 정보가 수정되었습니다.")

    except Exception as e:
        conn.rollback()
        print(f"오류 발생 : {e}")

    finally:
        cursor.close()
        conn.close()
```

- ► 사용 예시와 실행 결과
  ```python
  update_emp_sal(1001, 4000000)
  ```
  ```
  사원 정보가 수정되었습니다.
  ```
  수정 후 다시 조회하면 변경된 내용을 확인할 수 있다.
  ```python
  select_emp_by_empno(1001)
  ```
  ```
  (1001, 'KIM', 'DEVELOPER', datetime.date(2022, 3, 1), Decimal('4000000.00'), 10)
  ```

### ⌨️ 예제: 여러 컬럼 수정하기

`SET` 절에는 여러 개의 컬럼을 지정할 수 있다.

```python
def update_emp(empno, job, sal):
    conn = get_connection()
    cursor = conn.cursor()

    try:
        sql = """
            UPDATE emp
            SET
                job = %s,
                sal = %s
            WHERE empno = %s
        """

        cursor.execute(sql, (job, sal, empno))

        conn.commit()

        print("사원 정보가 수정되었습니다.")

    except Exception as e:
        conn.rollback()
        print(f"오류 발생 : {e}")

    finally:
        cursor.close()
        conn.close()
```

- ► 사용 예시와 실행 결과
  ```python
  update_emp(
      1007,
      "SENIOR SALESMAN",
      3800000
  )
  ```
  ```
  사원 정보가 수정되었습니다.
  ```
  변경 내용을 조회하면 다음과 같다.
  ```python
  select_emp_by_empno(1007)
  ```
  ```
  (1007, 'YOON', 'SENIOR SALESMAN', datetime.date(2021, 12, 20), Decimal('3800000.00'), 30)
  ```

### 📘 `execute()` : 실행된 행(Row)의 개수 반환

`execute()`는 SQL 실행 후 영향을 받은 행(row)의 개수를 반환한다.

```python
count = cursor.execute(sql, (sal, empno))

print(count)
```

#### 실행 결과

```
1
```

조건에 맞는 데이터가 없으면 다음과 같이 반환된다.

```
0
```

이를 이용하면 수정 성공 여부를 간단하게 확인할 수 있다.

```python
count = cursor.execute(sql, (sal, empno))

if count > 0:
    conn.commit()
    print("수정 완료")
else:
    print("수정할 데이터가 없습니다.")
```

<br/>

## 🗑️ DELETE (삭제)

데이터를 삭제할 때, SQL에서는 `DELETE` 문을 사용한다.

데이터를 변경하는 작업이므로 `INSERT`, `UPDATE`와 마찬가지로 **트랜잭션(commit / rollback)** 처리가 필요하다.

### 🔖 기본 작성 포맷

PyMySQL을 사용한 삭제 함수는 일반적으로 다음과 같은 구조로 작성한다.

```python
def 함수명():
    conn = get_connection()
    cursor = conn.cursor()

    try:
        sql = """
            DELETE FROM 테이블명
            WHERE 조건
        """

        cursor.execute(sql, 값)

        conn.commit()

    except Exception:
        conn.rollback()

    finally:
        cursor.close()
        conn.close()
```

### ⌨️ 예제: 사원 삭제

사원번호를 기준으로 사원 정보를 삭제하는 함수이다.

```python
def delete_emp(empno):
    conn = get_connection()
    cursor = conn.cursor()

    try:
        sql = """
            DELETE FROM emp
            WHERE empno = %s
        """

        count = cursor.execute(sql, (empno,))

        if count > 0:
            conn.commit()
            print("사원 정보가 삭제되었습니다.")
        else:
            print("삭제할 사원이 존재하지 않습니다.")

    except Exception as e:
        conn.rollback()
        print(f"오류 발생 : {e}")

    finally:
        cursor.close()
        conn.close()
```

- ► 사용 예시와 실행 결과
  ```python
  delete_emp(1011)
  ```
  ```
  사원 정보가 삭제되었습니다.
  ```
  삭제 후 다시 조회하면 해당 사원이 더 이상 존재하지 않는 것을 확인할 수 있다.
  ```python
  select_emp_by_empno(1011)
  ```
  ```
  None
  ```

### 📘 존재하지 않는 데이터 삭제

조건에 맞는 데이터가 없더라도 `DELETE` 문은 오류가 발생하지 않는다.

대신 `execute()`의 반환값이 `0`이 된다.

```python
delete_emp(9999)
```

```
삭제할 사원이 존재하지 않습니다.
```

### 📘 `execute()` 반환값 활용

`execute()`는 영향을 받은 행(Row)의 개수를 반환한다.

```python
count = cursor.execute(sql, (empno,))
```

| 반환값 | 의미               |
| ------ | ------------------ |
| `1`    | 삭제 성공          |
| `0`    | 삭제할 데이터 없음 |

이를 이용하면 삭제 성공 여부를 쉽게 확인할 수 있다.

```python
count = cursor.execute(sql, (empno,))

if count > 0:
    conn.commit()
else:
    print("삭제할 사원이 존재하지 않습니다.")
```

> 💡**참고**
>
> `DELETE`는 데이터를 제거하지만 테이블 구조는 그대로 유지된다.
> 테이블의 모든 데이터를 빠르게 삭제하려면 `TRUNCATE TABLE`을 사용할 수도 있지만, `TRUNCATE`는 동작 방식과 트랜잭션 처리 방식이 다르므로 이번 포스팅에서는 가장 일반적으로 사용하는 `DELETE`를 기준으로 설명한다.

<br/>

## 🖥️ 통합 프로그램 구현

지금까지 작성한 CRUD 함수들을 하나의 프로그램에서 실행할 수 있도록 통합한다.

이 장에서는 단순히 메뉴를 출력하는 것뿐만 아니라, 사용자 입력을 안전하게 처리하기 위한 보조 함수도 함께 작성한다.

### ⌨️ 보조 함수

```python
from datetime import datetime

# 입력 처리 함수
def input_int(message):
    while True:
        try:
            return int(input(message))
        except ValueError:
            print("숫자만 입력해주세요.")

# 날짜 입력 처리 함수
def input_date(message):
    while True:
        value = input(message)

        try:
            datetime.strptime(value, "%Y-%m-%d")
            return value
        except ValueError:
            print("날짜는 YYYY-MM-DD 형식으로 입력해주세요.")

# 사원 정보 입력 함수
def input_emp_info():
    empno = input_int("사원번호 : ")
    ename = input("사원명 : ").upper()
    job = input("직급 : ").upper()
    hiredate = input_date("입사일(YYYY-MM-DD) : ")
    sal = input_int("급여 : ")
    deptno = input_int("부서번호 : ")

    return empno, ename, job, hiredate, sal, deptno
```

| 함수               | 역할                                                                                  |
| ------------------ | ------------------------------------------------------------------------------------- |
| `input_int()`      | 숫자 입력을 받아 정수(`int`)로 변환하며, 잘못된 입력이 들어오면 다시 입력받는다.      |
| `input_date()`     | 날짜를 입력받아 `YYYY-MM-DD` 형식인지 검증하고, 올바른 형식이 입력될 때까지 반복한다. |
| `input_emp_info()` | 사원 등록에 필요한 정보를 한 번에 입력받아 튜플 형태로 반환한다.                      |

### ⌨️ 통합 실행 함수

앞에서 만든 입력 처리 함수와 CRUD 함수를 연결한다.

```python
def main():
    while True:
        print("\n===== 사원 관리 시스템 =====")
        print("1. 전체 사원 조회")
        print("2. 사원 등록")
        print("3. 사원 급여 수정")
        print("4. 사원 삭제")
        print("0. 종료")

        menu = input("메뉴 선택 : ").strip()

        if menu == "1":
            select_all_emp()

        elif menu == "2":
            emp_info = input_emp_info()
            insert_emp(*emp_info)

        elif menu == "3":
            empno = input_int("사원번호 : ")
            sal = input_int("변경할 급여 : ")

            update_emp_sal(empno, sal)

        elif menu == "4":
            empno = input_int("삭제할 사원번호 : ")
            delete_emp(empno)

        elif menu == "0":
            print("프로그램을 종료합니다.")
            break

        else:
            print("올바른 메뉴를 선택해주세요.")
```

### ⌨️ 프로그램 실행

```python
if __name__ == "__main__":
    main()
```

<br/>

## 🛡️ SQL Injection 방지

데이터베이스와 연동하는 프로그램에서는 **SQL 문과 데이터를 분리하여 처리하는 것**이 매우 중요하다.

PyMySQL에서는 이를 위해 **파라미터 바인딩(Parameter Binding)** 기능을 제공한다.

이번 장에서는 파라미터 바인딩이 어떻게 동작하며, 왜 SQL Injection을 방지할 수 있는지 살펴본다.

### 📘 PyMySQL 내부 동작

`execute()`를 호출하면 다음과 같은 순서로 동작한다.

```
Python 코드
        │
        ▼
SQL 문
SELECT * FROM emp WHERE empno = %s
        │
        │
입력값
1001
        │
        ▼
PyMySQL
        │
(SQL과 데이터를 분리하여 전달)
        ▼
MySQL Server
        │
        ▼
SQL 실행
```

PyMySQL은 SQL과 입력값을 분리하여 처리한다.

입력값은 PyMySQL이 안전하게 처리한 후 SQL이 실행되므로, 입력값이 SQL 문법으로 해석되지 않아 SQL Injection을 예방할 수 있다.

### 📘 SQL Injection이 방지되는 이유

사용자가 다음과 같은 값을 입력했다고 가정해 보자.

```
' OR '1'='1
```

파라미터 바인딩을 사용하면 MySQL은 이것을

```
"' OR '1'='1"
```

이라는 하나의 문자열 데이터로 처리한다.

즉,

```
WHERE ename = "' OR '1'='1"
```

이라는 의미가 될 뿐, SQL 문장의 구조는 전혀 변경되지 않는다.

이처럼 파라미터 바인딩을 사용하면 입력값은 SQL 문장의 일부가 아니라 하나의 데이터로 전달된다.

따라서 입력값에 작은따옴표(`'`), `OR`, `--` 등의 SQL 문법에 사용되는 특수문자가 포함되어 있더라도 SQL 문법으로 해석되지 않고 일반 문자열로 처리되므로 SQL Injection을 방지할 수 있다.

### 📘 파라미터 바인딩의 추가 장점

파라미터 바인딩은 보안뿐만 아니라 데이터 처리도 편리하게 만들어 준다.

| 장점                  | 설명                                            |
| --------------------- | ----------------------------------------------- |
| SQL과 데이터를 분리   | SQL 구조가 변경되지 않는다.                     |
| SQL Injection 방지    | 입력값이 SQL 코드로 해석되지 않는다.            |
| 데이터 타입 자동 처리 | 문자열, 숫자, 날짜 등을 적절한 형태로 변환한다. |
| 코드 가독성 향상      | SQL과 데이터가 명확하게 구분된다.               |

<br/>

## 📌 정리

**PyMySQL 주요 객체**

| 객체         | 역할                       |
| ------------ | -------------------------- |
| `Connection` | MySQL 서버와 연결을 관리   |
| `Cursor`     | SQL을 실행하고 결과를 반환 |

**자주 사용하는 PyMySQL의 메서드**

| 메서드                | 설명              |
| --------------------- | ----------------- |
| `cursor.execute()`    | SQL을 실행        |
| `cursor.fetchone()`   | 결과 1건을 반환   |
| `cursor.fetchmany(n)` | 결과 n건을 반환   |
| `cursor.fetchall()`   | 전체 결과를 반환  |
| `conn.commit()`       | 변경 내용을 저장  |
| `conn.rollback()`     | 변경 내용을 취소  |
| `cursor.close()`      | Cursor를 종료     |
| `conn.close()`        | Connection을 종료 |

**트랜잭션**

- `SELECT`는 `commit()`이 필요하지 않음
- `INSERT`, `UPDATE`, `DELETE`는 `commit()`이 필요
- 오류 발생 시 `rollback()` 수행

**파라미터 바인딩**

- SQL과 데이터를 분리하여 전달
- SQL Injection 방지
- 값이 하나여도 `(value,)` 형태의 튜플 사용

**CRUD 기본 흐름**

- READ : `execute()` → `fetch()` → `close()`
- CREATE / UPDATE / DELETE : `execute()` → `commit()` → `close()`

**PyMySQL 작업 순서**

```
Connection 생성
        ↓
Cursor 생성
        ↓
SQL 작성 및 execute()
        ↓
READ  → fetch()
CUD   → commit()
        ↓
Cursor 종료
        ↓
Connection 종료
```
