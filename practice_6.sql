create database practice_6

create table departments(
    dept_id    varchar(10) primary key,
    dept_name   varchar(20),
    building    varchar(20)
);

create table instructors(
    instructor_id   varchar(10) primary key,
    name        varchar(20),
    dept_id     varchar(20)
);


create table courses(
    course_id varchar(10) primary key,
    title varchar(20),
    instructor_id varchar(20)
);



--Part A
---1.
cross join ---- 9
inner join ---- 2
left join ----- 3
right join ----- 3
full join ---- 4


--2.
both return 3 rows,but thr rows arent same
--3.-

-- name   i.depr_id      d.dept_id    dept_name
--aigerim  d1              d1           software
--bolat    d2       d2 math
--dana    null     null



--Part B

--1.
select c.course_id, c.title< i.name
from courses c
left join instructors i

--2.

--3.


--4.

--Part c
--1.

select i.name , d.ept
from instructirs i
left join departments d on i.dept_id = d.dept_id