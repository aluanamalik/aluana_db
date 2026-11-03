-- Lab 6: SQL JOINs

create database lab_6;

-- Part 1
create table employees (
    emp_id   int primary key,
    emp_name varchar(50),
    dept_id  int,
    salary   decimal(10, 2)
);

create table departments (
    dept_id   int primary key,
    dept_name varchar(50),
    location  varchar(50)
);

create table projects (
    project_id   int primary key,
    project_name varchar(50),
    dept_id      int,
    budget       decimal(10, 2)
);

insert into employees (emp_id, emp_name, dept_id, salary) values
(1, 'John Smith', 101, 50000),
(2, 'Jane Doe', 102, 60000),
(3, 'Mike Johnson', 101, 55000),
(4, 'Sarah Williams', 103, 65000),
(5, 'Tom Brown', null, 45000);

insert into departments (dept_id, dept_name, location) values
(101, 'IT', 'Building A'),
(102, 'HR', 'Building B'),
(103, 'Finance', 'Building C'),
(104, 'Marketing', 'Building D');

insert into projects (project_id, project_name, dept_id, budget) values
(1, 'Website Redesign', 101, 100000),
(2, 'Employee Training', 102, 50000),
(3, 'Budget Analysis', 103, 75000),
(4, 'Cloud Migration', 101, 150000),
(5, 'AI Research', null, 200000);


-- 2.1
select e.emp_name, d.dept_name
from employees e
cross join departments d;
-- Q: How many rows? N x M
-- A: 5 * 4 = 20 rows

-- 2.2 a)
select e.emp_name, d.dept_name
from employees e, departments d;

-- 2.2 b)
select e.emp_name, d.dept_name
from employees e
inner join departments d on true;

-- 2.3
select e.emp_name, p.project_name
from employees e
cross join projects p;


-- 3.1
select e.emp_name, d.dept_name, d.location
from employees e
inner join departments d on e.dept_id = d.dept_id;
-- Q: How many rows? Why is Tom Brown not included?
-- A: 4 rows; Tom has dept_id NULL, INNER JOIN keeps only matches

-- 3.2
select emp_name, dept_name, location
from employees
inner join departments using (dept_id);
-- Q: What's the difference in output columns compared to ON?
-- A: USING gives one shared dept_id; ON can show e.dept_id and d.dept_id separately

-- 3.3
select emp_name, dept_name, location
from employees
natural inner join departments;

-- 3.4
select e.emp_name, d.dept_name, p.project_name
from employees e
inner join departments d on e.dept_id = d.dept_id
inner join projects p on d.dept_id = p.dept_id;


-- 4.1
select e.emp_name, e.dept_id as emp_dept, d.dept_id as dept_dept, d.dept_name
from employees e
left join departments d on e.dept_id = d.dept_id;
-- Q: How is Tom Brown represented in the results?
-- A: emp_name = Tom Brown, emp_dept/dept_dept/dept_name = NULL

-- 4.2
select emp_name, dept_id, dept_name, location
from employees
left join departments using (dept_id);

-- 4.3
select e.emp_name, e.dept_id
from employees e
left join departments d on e.dept_id = d.dept_id
where d.dept_id is null;

-- 4.4
select d.dept_name, count(e.emp_id) as employee_count
from departments d
left join employees e on d.dept_id = e.dept_id
group by d.dept_id, d.dept_name
order by employee_count desc;


-- 5.1
select e.emp_name, d.dept_name
from employees e
right join departments d on e.dept_id = d.dept_id;

-- 5.2
select e.emp_name, d.dept_name
from departments d
left join employees e on d.dept_id = e.dept_id;

-- 5.3
select d.dept_name, d.location
from employees e
right join departments d on e.dept_id = d.dept_id
where e.emp_id is null;


-- 6.1
select e.emp_name, e.dept_id as emp_dept, d.dept_id as dept_dept, d.dept_name
from employees e
full join departments d on e.dept_id = d.dept_id;
-- Q: Which records have NULL on the left? On the right?
-- A: NULL left = Marketing; NULL right = Tom Brown

-- 6.2
select d.dept_name, p.project_name, p.budget
from departments d
full join projects p on d.dept_id = p.dept_id;

-- 6.3
select
    case
        when e.emp_id is null then 'Department without employees'
        when d.dept_id is null then 'Employee without department'
        else 'Matched'
    end as record_status,
    e.emp_name,
    d.dept_name
from employees e
full join departments d on e.dept_id = d.dept_id
where e.emp_id is null or d.dept_id is null;


-- 7.1
select e.emp_name, d.dept_name, e.salary
from employees e
left join departments d on e.dept_id = d.dept_id and d.location = 'Building A';

-- 7.2
select e.emp_name, d.dept_name, e.salary
from employees e
left join departments d on e.dept_id = d.dept_id
where d.location = 'Building A';
-- Q: Compare Query 1 (ON) and Query 2 (WHERE). Explain the difference.
-- A: ON keeps all employees (non-A get NULL dept); WHERE keeps only Building A matches

-- 7.3
select e.emp_name, d.dept_name, e.salary
from employees e
inner join departments d on e.dept_id = d.dept_id and d.location = 'Building A';

select e.emp_name, d.dept_name, e.salary
from employees e
inner join departments d on e.dept_id = d.dept_id
where d.location = 'Building A';
-- Q: Is there any difference with INNER JOIN? Why or why not?
-- A: No difference; INNER drops non-matches either way


-- 8.1
select d.dept_name, e.emp_name, e.salary, p.project_name, p.budget
from departments d
left join employees e on d.dept_id = e.dept_id
left join projects p on d.dept_id = p.dept_id
order by d.dept_name, e.emp_name;

-- 8.2
alter table employees add column manager_id int;

update employees set manager_id = 3 where emp_id = 1;
update employees set manager_id = 3 where emp_id = 2;
update employees set manager_id = null where emp_id = 3;
update employees set manager_id = 3 where emp_id = 4;
update employees set manager_id = 3 where emp_id = 5;

select e.emp_name as employee, m.emp_name as manager
from employees e
left join employees m on e.manager_id = m.emp_id;

-- 8.3
select d.dept_name, avg(e.salary) as avg_salary
from departments d
inner join employees e on d.dept_id = e.dept_id
group by d.dept_id, d.dept_name
having avg(e.salary) > 50000;


-- Lab Questions

-- 1. What is the difference between INNER JOIN and LEFT JOIN?
-- Answer: INNER JOIN returns only matching rows. LEFT JOIN returns all rows from the left table and matching rows from the right (NULL if no match).

-- 2. When would you use CROSS JOIN in a practical scenario?
-- Answer: For combinations/matrices, e.g. schedules, all employee-project pairs, calendar grids.

-- 3. Explain why the position of a filter condition (ON vs WHERE) matters for outer joins but not for inner joins.
-- Answer: For outer joins, ON is applied during the join (unmatched rows can stay with NULL). WHERE is applied after and can remove those rows. For inner joins non-matches are dropped either way, so ON and WHERE give the same result.

-- 4. What is the result of: SELECT COUNT(*) FROM table1 CROSS JOIN table2 if table1 has 5 rows and table2 has 10 rows?
-- Answer: 50

-- 5. How does NATURAL JOIN determine which columns to join on?
-- Answer: It joins on all columns that have the same names in both tables.

-- 6. What are the potential risks of using NATURAL JOIN?
-- Answer: It may join on unexpected same-named columns; schema changes can silently change the join; harder to read than explicit ON/USING.

-- 7. Convert this LEFT JOIN to a RIGHT JOIN: SELECT * FROM A LEFT JOIN B ON A.id = B.id
-- Answer: SELECT * FROM B RIGHT JOIN A ON A.id = B.id;

-- 8. When should you use FULL OUTER JOIN instead of other join types?
-- Answer: When you need unmatched rows from both sides in one result


-- Additional Challenges (Optional)

-- 1. Create a query that simulates FULL OUTER JOIN using UNION of LEFT and RIGHT joins
-- Answer:
select e.emp_name, d.dept_name
from employees e
left join departments d on e.dept_id = d.dept_id
union
select e.emp_name, d.dept_name
from employees e
right join departments d on e.dept_id = d.dept_id;

-- 2. Write a query to find employees who work in departments that have more than one project
-- Answer:
select distinct e.emp_name, d.dept_name
from employees e
inner join departments d on e.dept_id = d.dept_id
where d.dept_id in (
    select dept_id
    from projects
    where dept_id is not null
    group by dept_id
    having count(*) > 1
);

-- 3. Create a hierarchical query showing the complete organizational structure using self-joins
-- Answer:
select
    e.emp_name as employee,
    m.emp_name as manager,
    mm.emp_name as managers_manager
from employees e
left join employees m on e.manager_id = m.emp_id
left join employees mm on m.manager_id = mm.emp_id;

-- 4. Implement a query that finds all pairs of employees who work in the same department
-- Answer:
select
    e1.emp_name as employee_1,
    e2.emp_name as employee_2,
    e1.dept_id
from employees e1
inner join employees e2
    on e1.dept_id = e2.dept_id
   and e1.emp_id < e2.emp_id;
.
