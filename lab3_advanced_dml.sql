-- Part A
-- 1
CREATE DATABASE advanced_lab
    WITH OWNER = CURRENT_USER
         TEMPLATE = template0
         ENCODING = 'UTF8';



CREATE TABLE employees (
    emp_id     SERIAL PRIMARY KEY,
    first_name VARCHAR(50),
    last_name  VARCHAR(50),
    department VARCHAR(50) DEFAULT 'General',
    salary     INTEGER     DEFAULT 50000,
    hire_date  DATE        DEFAULT CURRENT_DATE,
    status     VARCHAR(20) DEFAULT 'Active'
);

CREATE TABLE departments (
    dept_id    SERIAL PRIMARY KEY,
    dept_name  VARCHAR(50),
    budget     INTEGER,
    manager_id INTEGER
);

CREATE TABLE projects (
    project_id   SERIAL PRIMARY KEY,
    project_name VARCHAR(100),
    dept_id      INTEGER,
    start_date   DATE,
    end_date     DATE,
    budget       INTEGER
);


-- Part B
-- 2
INSERT INTO employees (emp_id, first_name, last_name, department)
VALUES (DEFAULT, 'Nina', 'Clark', 'Finance');

-- 3
INSERT INTO employees (first_name, last_name, department, salary, hire_date, status)
VALUES ('Oscar', 'Lewis', 'HR', DEFAULT, '2024-01-10', DEFAULT);

-- 4
INSERT INTO departments (dept_name, budget, manager_id) VALUES
    ('Marketing', 70000, 5),
    ('Support',   45000, 6),
    ('R&D',      200000, 7);

-- 5
INSERT INTO employees (first_name, last_name, department, salary, hire_date)
VALUES (
    'Paula',
    'Walker',
    'IT',
    (50000 * 1.1)::INTEGER,
    CURRENT_DATE
);

-- 6
CREATE TEMP TABLE temp_employees AS
SELECT * FROM employees WHERE FALSE;

INSERT INTO temp_employees
SELECT *
FROM employees
WHERE department = 'IT';


-- Part C
-- 7
UPDATE employees
SET salary = (salary * 1.1)::INTEGER
WHERE salary IS NOT NULL;

-- 8
UPDATE employees
SET status = 'Senior'
WHERE salary > 60000
  AND hire_date < DATE '2020-01-01';

-- 9
UPDATE employees
SET department = CASE
    WHEN salary > 80000 THEN 'Management'
    WHEN salary BETWEEN 50000 AND 80000 THEN 'Senior'
    ELSE 'Junior'
END
WHERE salary IS NOT NULL;

-- 10
UPDATE employees
SET department = DEFAULT
WHERE status = 'Inactive';

-- 11
UPDATE departments
SET budget = (
    SELECT AVG(salary) * 1.2
    FROM employees
    WHERE employees.department = departments.dept_name
);

-- 12
UPDATE employees
SET
    salary = salary * 1.15,
    status = 'Promoted'
WHERE department = 'Sales';


-- Part D
-- 13
DELETE FROM employees
WHERE status = 'Terminated';

-- 14
DELETE FROM employees
WHERE salary < 40000
  AND hire_date > '2023-01-01'
  AND department IS NULL;

-- 15
DELETE FROM departments
WHERE dept_name NOT IN (
    SELECT department
    FROM employees
    WHERE department IS NOT NULL
);

-- 16
DELETE FROM projects
WHERE end_date < '2023-01-01'
RETURNING *;


-- Part E
-- 17
INSERT INTO employees (first_name, last_name, department, salary, hire_date, status)
VALUES ('Quinn', 'Young', NULL, NULL, CURRENT_DATE, 'Active');

-- 18
UPDATE employees
SET department = 'Unassigned'
WHERE department IS NULL;

-- 19
DELETE FROM employees
WHERE salary IS NULL
   OR department IS NULL;


-- Part F
-- 20
INSERT INTO employees (first_name, last_name, department, salary, hire_date)
VALUES ('Rachel', 'King', 'IT', 58000, CURRENT_DATE)
RETURNING
    emp_id,
    first_name || ' ' || last_name AS full_name;

-- 21
UPDATE employees
SET salary = salary + 5000
WHERE department = 'IT'
RETURNING
    emp_id,
    salary - 5000 AS old_salary,
    salary AS new_salary;

-- 22
DELETE FROM employees
WHERE hire_date < '2020-01-01'
RETURNING *;


-- Part G
-- 23
INSERT INTO employees (first_name, last_name, department, salary, hire_date)
SELECT 'Sam', 'Wright', 'IT', 56000, CURRENT_DATE
WHERE NOT EXISTS (
    SELECT *
    FROM employees
    WHERE first_name = 'Sam'
      AND last_name = 'Wright'
);

-- 24
UPDATE employees
SET salary = salary * 1.1
WHERE department IN (
    SELECT dept_name
    FROM departments
    WHERE budget > 100000
);

UPDATE employees
SET salary = salary * 1.05
WHERE department IN (
    SELECT dept_name
    FROM departments
    WHERE budget <= 100000
);

-- 25
INSERT INTO employees (first_name, last_name, department, salary, hire_date, status) VALUES
    ('Tom', 'Baker', 'BulkTest', 40000, CURRENT_DATE, 'Active'),
    ('Uma', 'Collins', 'BulkTest', 42000, CURRENT_DATE, 'Active'),
    ('Victor', 'Diaz', 'BulkTest', 44000, CURRENT_DATE, 'Active'),
    ('Wendy', 'Evans', 'BulkTest', 46000, CURRENT_DATE, 'Active'),
    ('Xander', 'Foster', 'BulkTest', 48000, CURRENT_DATE, 'Active');

UPDATE employees
SET salary = salary * 1.1
WHERE department = 'BulkTest';

-- 26
CREATE TABLE employee_archive AS
SELECT * FROM employees WHERE FALSE;

INSERT INTO employee_archive
SELECT * FROM employees
WHERE status = 'Inactive';

DELETE FROM employees
WHERE status = 'Inactive';

-- 27
UPDATE projects
SET end_date = end_date + INTERVAL '30 days'
WHERE budget > 50000
  AND (
      SELECT COUNT(*)
      FROM employees, departments
      WHERE departments.dept_id = projects.dept_id
        AND employees.department = departments.dept_name
  ) > 3;
