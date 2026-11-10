--Part 1
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

insert into employees values
(1, 'John Smith', 101, 50000),
(2, 'Jane Doe', 102, 60000),
(3, 'Mike Johnson', 101, 55000),
(4, 'Sarah Williams', 103, 65000),
(5, 'Tom Brown', null, 45000);

insert into departments values
(101, 'IT', 'Building A'),
(102, 'HR', 'Building B'),
(103, 'Finance', 'Building C'),
(104, 'Marketing', 'Building D');

insert into projects values
(1, 'Website Redesign', 101, 100000),
(2, 'Employee Training', 102, 50000),
(3, 'Budget Analysis', 103, 75000),
(4, 'Cloud Migration', 101, 150000),
(5, 'AI Research', null, 200000);


--Part 2
-- 2.1
create view employee_details as
select e.emp_name, e.salary, d.dept_name, d.location
from employees e
inner join departments d on e.dept_id = d.dept_id;

select * from employee_details;
-- answer: 4 rows; tom has dept_id null, inner join excludes him


-- 2.2
create view dept_statistics as
select
    d.dept_name,
    count(e.emp_id) as employee_count,
    avg(e.salary) as average_salary,
    max(e.salary) as maximum_salary,
    min(e.salary) as minimum_salary
from departments d
left join employees e on d.dept_id = e.dept_id
group by d.dept_id, d.dept_name;

select * from dept_statistics
order by employee_count desc;


-- 2.3
create view project_overview as
select
    p.project_name,
    p.budget,
    d.dept_name,
    d.location,
    count(e.emp_id) as team_size
from projects p
left join departments d on p.dept_id = d.dept_id
left join employees e on d.dept_id = e.dept_id
group by p.project_id, p.project_name, p.budget, d.dept_name, d.location;


-- 2.4
create view high_earners as
select e.emp_name, e.salary, d.dept_name
from employees e
left join departments d on e.dept_id = d.dept_id
where e.salary > 55000;

select * from high_earners;
-- answer: returns jane (60000) and sarah (65000). yes, all employees with salary > 55000


--Part 3
-- 3.1
create or replace view employee_details as
select
    e.emp_name,
    e.salary,
    d.dept_name,
    d.location,
    case
        when e.salary > 60000 then 'High'
        when e.salary > 50000 then 'Medium'
        else 'Standard'
    end as salary_grade
from employees e
inner join departments d on e.dept_id = d.dept_id;


-- 3.2
alter view high_earners rename to top_performers;
select * from top_performers;


-- 3.3
create view temp_view as
select emp_name, salary
from employees
where salary < 50000;

drop view temp_view;


--Part 4
-- 4.1
create view employee_salaries as
select emp_id, emp_name, dept_id, salary
from employees;


-- 4.2
update employee_salaries
set salary = 52000
where emp_name = 'John Smith';

select * from employees where emp_name = 'John Smith';
-- answer: yes, the base table employees was updated through the view


-- 4.3
insert into employee_salaries (emp_id, emp_name, dept_id, salary)
values (6, 'Arai Johnson', 102, 58000);

select * from employees where emp_id = 6;
-- answer: yes, arai johnson appears in employees


-- 4.4
create view it_employees as
select emp_id, emp_name, dept_id, salary
from employees
where dept_id = 101
with local check option;
-- answer: new row violates check option for view it_employees, dept_id 103 is not allowed by the view


--Part 5
-- 5.1
create materialized view dept_summary_mv as
select
    d.dept_id,
    d.dept_name,
    coalesce(e.total_employees, 0) as total_employees,
    coalesce(e.total_salaries, 0) as total_salaries,
    coalesce(p.total_projects, 0) as total_projects,
    coalesce(p.total_budget, 0) as total_project_budget
from departments d
left join (
    select dept_id, count(*) as total_employees, sum(salary) as total_salaries
    from employees
    group by dept_id
) e on d.dept_id = e.dept_id
left join (
    select dept_id, count(*) as total_projects, sum(budget) as total_budget
    from projects
    group by dept_id
) p on d.dept_id = p.dept_id
with data;

select * from dept_summary_mv order by total_employees desc;


-- 5.2
insert into employees values (8, 'Charlie Brown', 101, 54000);

select * from dept_summary_mv where dept_id = 101;

refresh materialized view dept_summary_mv;

select * from dept_summary_mv where dept_id = 101;
-- answer: before refresh it employee salaries are old. after refresh charlie is included


-- 5.3
create unique index dept_summary_mv_dept_id_idx on dept_summary_mv (dept_id);

refresh materialized view concurrently dept_summary_mv;
-- answer: readers can still query the mv during refresh


-- 5.4
create materialized view project_stats_mv as
select
    p.project_name,
    p.budget,
    d.dept_name,
    count(e.emp_id) as assigned_employees
from projects p
left join departments d on p.dept_id = d.dept_id
left join employees e on d.dept_id = e.dept_id
group by p.project_id, p.project_name, p.budget, d.dept_name
with no data;

-- select * from project_stats_mv
-- answer: materialized view "project_stats_mv" has not been populated; fix: refresh materialized view project_stats_mv

refresh materialized view project_stats_mv;
select * from project_stats_mv;


--Part 6
-- 6.1
create role analyst;
create role data_viewer login password 'viewer123';
create user report_user password 'report456';

select rolname from pg_roles where rolname not like 'pg_%';


-- 6.2
create role db_creator login password 'creator789' createdb;
create role user_manager login password 'manager101' createrole;
create role admin_user login password 'admin999' superuser;


-- 6.3
grant select on employees, departments, projects to analyst;
grant all privileges on employee_details to data_viewer;
grant select, insert on employees to report_user;


-- 6.4
create role hr_team;
create role finance_team;
create role it_team;

create user hr_user1 password 'hr001';
create user hr_user2 password 'hr002';
create user finance_user1 password 'fin001';

grant hr_team to hr_user1, hr_user2;
grant finance_team to finance_user1;

grant select, update on employees to hr_team;
grant select on dept_statistics to finance_team;


-- 6.5
revoke update on employees from hr_team;
revoke hr_team from hr_user2;
revoke all privileges on employee_details from data_viewer;


-- 6.6
alter role analyst login password 'analyst123';
alter role user_manager superuser;
alter role analyst password null;
alter role data_viewer connection limit 5;


--Part 7
-- 7.1
create role read_only;
grant select on all tables in schema public to read_only;

create user junior_analyst password 'junior123';
create user senior_analyst password 'senior123';

grant read_only to junior_analyst, senior_analyst;
grant insert, update on employees to senior_analyst;


-- 7.2
create role project_manager login password 'pm123';

alter view dept_statistics owner to project_manager;
alter table projects owner to project_manager;

select tablename, tableowner
from pg_tables
where schemaname = 'public';


-- 7.3
create role temp_owner login;
create table temp_table (id int);
alter table temp_table owner to temp_owner;
reassign owned by temp_owner to current_user;
drop owned by temp_owner;
drop role temp_owner;


-- 7.4
create view hr_employee_view as
select emp_id, emp_name, dept_id, salary
from employees
where dept_id = 102;

grant select on hr_employee_view to hr_team;

create view finance_employee_view as
select emp_id, emp_name, salary
from employees;

grant select on finance_employee_view to finance_team;


--Part 8
-- 8.1
create view dept_dashboard as
select
    d.dept_name,
    d.location,
    coalesce(e.employee_count, 0) as employee_count,
    round(coalesce(e.average_salary, 0), 2) as average_salary,
    coalesce(p.active_projects, 0) as active_projects,
    coalesce(p.total_project_budget, 0) as total_project_budget,
    round(
        coalesce(p.total_project_budget, 0) / nullif(e.employee_count, 0),
        2
    ) as budget_per_employee
from departments d
left join (
    select dept_id,
           count(*) as employee_count,
           avg(salary) as average_salary
    from employees
    group by dept_id
) e on d.dept_id = e.dept_id
left join (
    select dept_id,
           count(*) as active_projects,
           sum(budget) as total_project_budget
    from projects
    group by dept_id
) p on d.dept_id = p.dept_id;


-- 8.2
alter table projects add column created_date timestamp default current_timestamp;

create view high_budget_projects as
select
    p.project_name,
    p.budget,
    d.dept_name,
    p.created_date,
    case
        when p.budget > 150000 then 'Critical Review Required'
        when p.budget > 100000 then 'Management Approval Needed'
        else 'Standard Process'
    end as approval_status
from projects p
left join departments d on p.dept_id = d.dept_id
where p.budget > 75000;


-- 8.3
create role viewer_role;
grant select on all tables in schema public to viewer_role;

create role entry_role;
grant viewer_role to entry_role;
grant insert on employees, projects to entry_role;

create role analyst_role;
grant entry_role to analyst_role;
grant update on employees, projects to analyst_role;

create role manager_role;
grant analyst_role to manager_role;
grant delete on employees, projects to manager_role;

create user arai password 'alice123';
create user bob password 'bob123';
create user charlie password 'charlie123';

grant viewer_role to arai;
grant analyst_role to bob;
grant manager_role to charlie;
