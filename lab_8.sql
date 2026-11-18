-- Laboratory Work 8: SQL Indexes
-- Name: Bayaly Arai
-- Student ID: [fill in]


--part 1: database setup

drop table if exists projects cascade;
drop table if exists employees cascade;
drop table if exists departments cascade;

create table departments(
    dept_id    int primary key,
    dept_name  varchar(50),
    location   varchar(50)
);

create table employees(
    emp_id    int primary key,
    emp_name  varchar(100),
    dept_id   int,
    salary    decimal(10,2),
    foreign key (dept_id) references departments(dept_id)
);

create table projects(
    proj_id    int primary key,
    proj_name  varchar(100),
    budget     decimal(12,2),
    dept_id    int,
    foreign key (dept_id) references departments(dept_id)
);

insert into departments values
    (101, 'IT', 'Building A'),
    (102, 'HR', 'Building B'),
    (103, 'Operations', 'Building C');

insert into employees values
    (1, 'John Smith', 101, 50000),
    (2, 'Jane Doe', 101, 55000),
    (3, 'Mike Johnson', 102, 48000),
    (4, 'Sarah Williams', 102, 52000),
    (5, 'Tom Brown', 103, 60000);

insert into projects values
    (201, 'Website Redesign', 75000, 101),
    (202, 'Database Migration', 120000, 101),
    (203, 'HR System Upgrade', 50000, 102);


--Part 2: Creating Basic Indexes

---2.1
create index emp_salary_idx on employees(salary);

select indexname, indexdef
from pg_indexes
where tablename = 'employees';
-- Q: How many indexes exist on employees?
-- A: At least 2 — employees_pkey (auto from PRIMARY KEY) and emp_salary_idx

---2.2
create index emp_dept_idx on employees(dept_id);

select * from employees where dept_id = 101;
-- Q: Why index foreign key columns?
-- A: JOINs and WHERE on FK are common; index makes those lookups faster

---2.3
select tablename, indexname, indexdef
from pg_indexes
where schemaname = 'public'
order by tablename, indexname;
-- Q: Which indexes were created automatically?
-- A: PRIMARY KEY indexes: departments_pkey, employees_pkey, projects_pkey


--Part 3: Multicolumn Indexes

---3.1
create index emp_dept_salary_idx on employees(dept_id, salary);

select emp_name, salary
from employees
where dept_id = 101 and salary > 52000;
-- Q: Useful for query that only filters by salary (no dept_id)?
-- A: No — leftmost column is dept_id; salary-only filter usually cannot use this index well

---3.2
create index emp_salary_dept_idx on employees(salary, dept_id);

select * from employees where dept_id = 102 and salary > 50000;
select * from employees where salary > 50000 and dept_id = 102;
-- Q: Does column order in multicolumn index matter?
-- A: Yes — index works best when query filters match the leftmost columns first


--Part 4: Unique Indexes

---4.1
alter table employees add column email varchar(100);

update employees set email = 'john.smith@company.com' where emp_id = 1;
update employees set email = 'jane.doe@company.com' where emp_id = 2;
update employees set email = 'mike.johnson@company.com' where emp_id = 3;
update employees set email = 'sarah.williams@company.com' where emp_id = 4;
update employees set email = 'tom.brown@company.com' where emp_id = 5;

create unique index emp_email_unique_idx on employees(email);

-- insert into employees (emp_id, emp_name, dept_id, salary, email)
-- values (6, 'New Employee', 101, 55000, 'john.smith@company.com');
-- Q: What error?
-- A: unique violation / duplicate key on emp_email_unique_idx

---4.2
alter table employees add column phone varchar(20) unique;

select indexname, indexdef
from pg_indexes
where tablename = 'employees' and indexname like '%phone%';
-- Q: Did PostgreSQL create an index automatically? What type?
-- A: Yes — unique B-tree index for the UNIQUE constraint


--Part 5: Indexes and Sorting

---5.1
create index emp_salary_desc_idx on employees(salary desc);

select emp_name, salary
from employees
order by salary desc;
-- Q: How does this help ORDER BY?
-- A: Data can be read already sorted DESC, so sorting work is reduced

---5.2
create index proj_budget_nulls_first_idx on projects(budget nulls first);

select proj_name, budget
from projects
order by budget nulls first;


--Part 6: Indexes on Expressions

---6.1
create index emp_name_lower_idx on employees(lower(emp_name));

select * from employees where lower(emp_name) = 'john smith';
-- Q: Without this index, how would PostgreSQL search case-insensitively?
-- A: Seq scan / compute LOWER() for every row and compare

---6.2
alter table employees add column hire_date date;

update employees set hire_date = '2020-01-15' where emp_id = 1;
update employees set hire_date = '2019-06-20' where emp_id = 2;
update employees set hire_date = '2021-03-10' where emp_id = 3;
update employees set hire_date = '2020-11-05' where emp_id = 4;
update employees set hire_date = '2018-08-25' where emp_id = 5;

create index emp_hire_year_idx on employees(extract(year from hire_date));

select emp_name, hire_date
from employees
where extract(year from hire_date) = 2020;


--Part 7: Managing Indexes

---7.1
alter index emp_salary_idx rename to employees_salary_index;

select indexname from pg_indexes where tablename = 'employees';

---7.2
drop index emp_salary_dept_idx;
-- Q: Why drop an index?
-- A: Unused/duplicate indexes slow writes and waste disk space

---7.3
reindex index employees_salary_index;
-- REINDEX useful after bulk inserts, bloat, or many updates/deletes


--Part 8: Practical Scenarios

---8.1
create index emp_salary_filter_idx on employees(salary) where salary > 50000;

select e.emp_name, e.salary, d.dept_name
from employees e
join departments d on e.dept_id = d.dept_id
where e.salary > 50000
order by e.salary desc;

---8.2
create index proj_high_budget_idx on projects(budget)
where budget > 80000;

select proj_name, budget
from projects
where budget > 80000;
-- Q: Advantage of partial index?
-- A: Smaller and faster — indexes only the rows you actually query often

---8.3
explain select * from employees where salary > 52000;
-- Q: Index Scan or Seq Scan?
-- A: Depends on data size; with few rows often Seq Scan; Index Scan means index is used


--Part 9: Index Types Comparison

---9.1
create index dept_name_hash_idx on departments using hash (dept_name);

select * from departments where dept_name = 'IT';
-- Q: When use HASH instead of B-tree?
-- A: Only for equality (=) lookups; B-tree is better for ranges and ORDER BY

---9.2
create index proj_name_btree_idx on projects(proj_name);
create index proj_name_hash_idx on projects using hash (proj_name);

select * from projects where proj_name = 'Website Redesign';
select * from projects where proj_name > 'Database';
-- Equality: both ok. Range (>): only B-tree


--Part 10: Cleanup and Best Practices

---10.1
select
    schemaname,
    tablename,
    indexname,
    pg_size_pretty(pg_relation_size(indexname::regclass)) as index_size
from pg_indexes
where schemaname = 'public'
order by tablename, indexname;
-- Q: Which index is largest? Why?
-- A: Usually the one on more/wider data or more rows; with small sample data sizes are tiny

---10.2
drop index if exists proj_name_hash_idx;

---10.3
create view index_documentation as
select
    tablename,
    indexname,
    indexdef,
    'Improves salary-based queries' as purpose
from pg_indexes
where schemaname = 'public'
  and indexname like '%salary%';

select * from index_documentation;


--summary answers
-- 1) the default index type in postgresql is b-tree
-- 2) create an index when you often use where, join, or order by on a large table
-- 3) do not create an index if the table is small or the column is almost never used in queries
-- 4) when you insert update or delete, indexes are updated too, so writes become slower
-- 5) use explain or explain analyze to see if the query uses an index


--brief reflection
-- indexes make select faster because the database does not need to scan the whole table
-- but insert update and delete become slower, and indexes also take disk space
-- i create indexes only for columns that i use a lot in where join or order by
-- i check with explain if the index is really used


--additional challenges

---1 find employees hired in a specific month
create index emp_hire_month_idx on employees(extract(month from hire_date));

select emp_name, hire_date
from employees
where extract(month from hire_date) = 1;

---2 unique index on dept_id and email together
create unique index emp_dept_email_uidx on employees(dept_id, email);

---3 compare the query plan with explain analyze
explain analyze
select * from employees where salary > 52000;

---4 covering index for one query
create index emp_cover_idx on employees(dept_id) include (emp_name, salary);

select emp_name, salary
from employees
where dept_id = 101;
