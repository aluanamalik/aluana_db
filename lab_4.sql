create database lab4
with owner = postgres
template = template0
encoding = 'UTF8'

--create

CREATE TABLE employees (
 employee_id SERIAL PRIMARY KEY,
 first_name VARCHAR(50),
 last_name VARCHAR(50),
 department VARCHAR(50),
 salary NUMERIC(10,2),
 hire_date DATE,
 manager_id INTEGER,
 email VARCHAR(100)
);

CREATE TABLE projects (
 project_id SERIAL PRIMARY KEY,
 project_name VARCHAR(100),
 budget NUMERIC(12,2),
 start_date DATE,
 end_date DATE,
 status VARCHAR(20)
);

CREATE TABLE assignments (
 assignment_id SERIAL PRIMARY KEY,
 employee_id INTEGER REFERENCES employees(employee_id),
 project_id INTEGER REFERENCES projects(project_id),
 hours_worked NUMERIC(5,1),
 assignment_date DATE
);

--insert


INSERT INTO employees (first_name, last_name, department,
salary, hire_date, manager_id, email) VALUES
('John', 'Smith', 'IT', 75000, '2020-01-15', NULL,
'john.smith@company.com'),
('Sarah', 'Johnson', 'IT', 65000, '2020-03-20', 1,
'sarah.j@company.com'),
('Michael', 'Brown', 'Sales', 55000, '2019-06-10', NULL,
'mbrown@company.com'),
('Emily', 'Davis', 'HR', 60000, '2021-02-01', NULL,
'emily.davis@company.com'),
('Robert', 'Wilson', 'IT', 70000, '2020-08-15', 1, NULL),
('Lisa', 'Anderson', 'Sales', 58000, '2021-05-20', 3,
'lisa.a@company.com');

INSERT INTO projects (project_name, budget, start_date,
end_date, status) VALUES
('Website Redesign', 150000, '2024-01-01', '2024-06-30',
'Active'),
('CRM Implementation', 200000, '2024-02-15', '2024-12-31',
'Active'),
('Marketing Campaign', 80000, '2024-03-01', '2024-05-31',
'Completed'),
('Database Migration', 120000, '2024-01-10', NULL, 'Active');

INSERT INTO assignments (employee_id, project_id,
hours_worked, assignment_date) VALUES
(1, 1, 120.5, '2024-01-15'),
(2, 1, 95.0, '2024-01-20'),
(1, 4, 80.0, '2024-02-01'),
(3, 3, 60.0, '2024-03-05'),
(5, 2, 110.0, '2024-02-20'),
(6, 3, 75.5, '2024-03-10');

--Part 1
--1.1
select employees.first_name || ' ' || employees.last_name as full_name, employees.department, employees.salary
from employees;

--1.2
select distinct employees.department from employees order by department;

--1.3
select projects.project_name, projects.budget,
       case
           when projects.budget > 150000 then 'Large'
           when projects.budget between 100000 and 150000 then 'Medium'
           else 'Small'
       end as budget_category
from projects;

--1.4
select employees.first_name,
       coalesce(email, 'No email provided') as email from employees;


--Part 2
--2.1
select * from employees
         where hire_date > '2020-01-01';

--2.2
select * from employees
         where salary between 60000 and 70000;

--2.3
select * from employees
         where last_name like 'S%'
         or last_name like 'J%';

--2.4
select * from employees
         where manager_id is not null
         and department = 'IT';


--Part 3
--3.1
select upper(employees.first_name) ||' '|| upper(employees.last_name) from employees;

select length(employees.last_name) from employees;

select substring(employees.email from 1 for 3) from employees;

--3.2
select
    employees.first_name || ' ' || employees.last_name as full_name,
    employees.salary as annual_salary,
    round(employees.salary / 12, 2) as monthly_salary,
    employees.salary * 0.10 as raise_salary
from employees;

--3.3
select format(
       'Project: %s - Budget: $%s - Status: %s',
       projects.project_name, projects.budget, projects.status
       ) from projects;

--3.4
select employees.hire_date,
    extract(year from age('2026-07-10', hire_date))::integer as year_with_company
from employees;

--Part 4
--4.1
select employees.department,
       avg(employees.salary) from employees
       group by department;

--4.2
select projects.project_name,
    sum(a.hours_worked) as total_hours
from projects
join assignments a on projects.project_id = a.project_id
group by project_name;

--4.3
select employees.department,
       count(*) as employee_count
from employees
group by department
having count(*) > 1
order by department;

--4.4
select max(employees.salary) as max_salary,
       min(employees.salary) as min_salary,
       sum(employees.salary) as total_pay
from employees;

--Part 5
--5.1
select employees.employee_id,
       employees.first_name || ' ' || employees.last_name as full_name,
       employees.salary from employees
               where salary > 65000
union
select employees.employee_id,
       employees.first_name || ' ' || employees.last_name,
       employees.salary
from employees
       where hire_date > date '2020-01-01';

--5.2
select employees.employee_id,
       employees.first_name || ' ' || employees.last_name as full_name,
       employees.salary
from employees where department = 'IT';
intersect
select employees.employee_id,
       employees.first_name || ' ' || employees.last_name
       from employees where salary > 65000;

--5.3
select employees.employee_id,
       employees.first_name || ' ' || employees.last_name as full_name
from employees
except
select e.employee_id,
    e.first_name || ' ' || e.last_name
from employees as e
join assignments as a on a.employee_id = e.employee_id;


--Part 6
--6.1
select employees.employee_id,
       employees.first_name,
       employees.last_name
from employees where exists(
    select 1 from assignments where assignments.employee_id = employees.employee_id
);

--6.2
select * from employees
   where employee_id in(
         select employee_id from assignments
                            join projects p on assignments.project_id = p.project_id
                            where status = 'Active'
         );

--6.3
select * from employees where salary > any(
    select  salary from employees
                   where department = 'Sales'
    );


--Part 7
--7.1
select
    employees.first_name || ' ' || employees.last_name as employee_name,
    employees.department,
    ROUND(AVG(assignments.hours_worked), 2) as avg_hours,
    employees.salary
from employees
left join assignments on assignments.employee_id = employees.employee_id
group by employees.employee_id, employees.first_name, employees.last_name,
         employees.department, employees.salary
order by employees.department, employees.salary desc;

--7.2
select
    projects.project_name,
    sum(assignments.hours_worked) as total_hours,
    count(distinct assignments.employee_id) as employees_assigned
from projects
join assignments on assignments.project_id = projects.project_id
group by projects.project_id, projects.project_name
having sum(assignments.hours_worked) > 150;

--7.3
select
    department,
    count(*) as employee_count,
    round(avg(salary), 2) as avg_salary,
    (select first_name || ' ' || last_name
     from employees as other
     where other.department = employees.department
     order by salary desc
     limit 1) as highest_paid_employee,
    greatest(max(salary), round(avg(salary), 2)),
    least(max(salary), round(avg(salary), 2))
from employees
group by department;
