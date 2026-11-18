create database practice_7

DROP TABLE IF EXISTS staff, departments CASCADE;

CREATE TABLE departments (
    dept_id   char(3)     PRIMARY KEY,
    dept_name varchar(12) NOT NULL,
    city      varchar(10) NOT NULL
);

CREATE TABLE staff (
    staff_id  char(3)     PRIMARY KEY,
    full_name varchar(14) NOT NULL,
    dept_id   char(3)     REFERENCES departments,
    salary    int         NOT NULL
);

INSERT INTO departments VALUES
('D10','Engineering','Almaty'),
('D20','Analytics',  'Astana'),
('D30','Design',     'Almaty');    -- nobody works here

INSERT INTO staff VALUES
('S1','Aisha Serik','D10', 620000),
('S2','Bekzat Nur', 'D10', 480000),
('S3','Clara Ten',  'D20', 550000),
('S4','Damir Ali',  'D20', 410000),
('S5','Elmira Kos', NULL,  390000);  -- no department



--Part A
-- 1
create view v_staff as
select * from staff;
select count(*) from v_staff;
insert into staff values('S6', 'Arai Bayaly', 'D20', 420000);
select count(*) from v_staff;
 -- it doest store rows it just run it again


-- 2
alter table staff add column bonus int default 0;
select * from v_staff
-- when viewwas created, postgre saved the list

--3
create or replace view v_staff as
select staff_id, full_name, dept_id, salary, bonus
from staff;

--Part B
--1
CREATE VIEW v_eng AS SELECT staff_id, full_name, dept_id, salary
FROM staff WHERE dept_id = 'D10';




--2
select count(*) from v_eng;
update v_eng
set salary = salary + 50000
where staff_id = 'S1';
select * from staff where staff_id = 'S1';


--3
update v_eng
set dept_id
