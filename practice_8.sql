create database practice_8;
-- ============================================================
-- In-Class Task: Does the Index Actually Get Used?
-- Laboratory Work 8 - SQL Indexes.  PostgreSQL 12+ (tested on 16).
-- Run this setup first, then work through steps 1-5 on the handout.
-- ============================================================

DROP TABLE IF EXISTS staff;

CREATE TABLE staff (
    staff_id  INT PRIMARY KEY,
    full_name VARCHAR(60)   NOT NULL,
    dept_id   INT           NOT NULL,
    city      VARCHAR(30)   NOT NULL,
    salary    NUMERIC(10,2) NOT NULL,
    hired_on  DATE          NOT NULL,
    active    BOOLEAN       NOT NULL
);

INSERT INTO staff
SELECT g,
       'Employee ' || g,
       1 + g % 12,
       (ARRAY['Almaty','Astana','Shymkent','Aktobe'])[1 + g % 4],
       40000 + (g * 37) % 60000,
       DATE '2015-01-01' + (g % 3800),
       (g % 50 <> 0)
  FROM generate_series(1, 200000) g;

ANALYZE staff;



--1.
EXPLAIN (ANALYZE, COSTS OFF) SELECT * FROM staff WHERE hired_on = DATE '2021-06-15';
CREATE INDEX staff_hired_idx ON staff(hired_on);
EXPLAIN (ANALYZE, COSTS OFF) SELECT * FROM staff WHERE hired_on = DATE '2021-06-15';
-- До индекста seq scan читает всю таблицу потому что еще на hired_on нету индектса (200000 строка)
    --после индектса bitmap index нашел 53 строки время 0.608
    --второй запрос быстрее первого потому что индекст показывает сразу нужные строки а не всю таблицу сперва читает





--2.

EXPLAIN (ANALYZE, COSTS OFF) SELECT * FROM staff WHERE hired_on >= DATE '2016-01-01';
EXPLAIN (ANALYZE, COSTS OFF) SELECT * FROM staff WHERE hired_on >= DATE '2025-01-01';
-- идекст подходит обоим но не всегда берется
    --запрос 2016-01-01 очень много строк. дешевле будет ппрочитать всю таблицу чем читать интекс и потом все страницы
--2025 -01-01


--3.

CREATE INDEX staff_dept_salary_idx ON staff(dept_id, salary);
EXPLAIN (COSTS OFF) SELECT * FROM staff WHERE dept_id = 7 AND salary > 90000;
EXPLAIN (COSTS OFF) SELECT * FROM staff WHERE salary > 90000;


--4
CREATE INDEX staff_lower_name_idx ON staff(LOWER(full_name));
EXPLAIN (COSTS OFF) SELECT * FROM staff WHERE LOWER(full_name) = 'employee 4242';
EXPLAIN (COSTS OFF) SELECT * FROM staff WHERE full_name = 'Employee 4242';

--5
CREATE INDEX staff_inactive_idx ON staff(hired_on) WHERE NOT active;
SELECT indexname, pg_size_pretty(pg_relation_size(indexname::regclass)) AS size
FROM pg_indexes WHERE tablename = 'staff' ORDER BY indexname;
EXPLAIN (COSTS OFF) SELECT * FROM staff WHERE NOT active AND hired_on < DATE '2016-01-01';
 --