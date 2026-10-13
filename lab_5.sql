create database lab_5;

--Part 1
---1.1

create table employees(
    employee_id  integer,
    first_name   text,
    last_name    text,
    age          integer check(age >= 18 and age <= 65),
    salary       numeric check(salary > 0)
);

---1.2

create table products_catalog(
    product_id       integer,
    product_name     text,
    regular_price    numeric,
    discount_price   numeric,
    constraint valid_discount check(
        regular_price > 0
        and discount_price > 0
        and discount_price < regular_price
        )
);

---1.3

create table bookings(
    booking_id      integer,
    check_in_date   date,
    check_out_date  date,
    num_guests      integer check(num_guests >= 1 and num_guests <= 10),
    check(check_out_date > check_in_date)
);

---1.4

insert into employees values (1, 'Arai', 'Bayaly', 23, 40000);
insert into employees values (2, 'Sanzhar', 'Malik', 26, 50000);

insert into products_catalog values (1, 'Mouse', 20, 15);
insert into products_catalog values (2, 'USB', 40, 30);

insert into bookings values (1, '2026-05-01', '2026-05-05', 2);
insert into bookings values (2, '2026-06-10', '2026-06-12', 4);


--Part 2
---2.1

create table customers(
    customer_id          integer not null,
    email                text not null,
    phone                text null,
    registration_date    date not null
);

---2.2

create table inventory(
    item_id      integer not null,
    item_name    text not null,
    quantity     integer not null check(quantity >= 0),
    unit_price   numeric not null check(unit_price > 0),
    last_updated timestamp not null
);

---2.3

insert into customers values (1, 'arai@gmail.com', '87075131103', '2026-01-15');
insert into customers values (2, 'sanzhar@gmail.com', '87072001512', '2026-02-02');
insert into customers values (3, 'omar@gmail.com', null, '2026-03-10');

insert into inventory values (1, 'HDMI', 50, 10, '2026-03-19');
insert into inventory values (2, 'Stand', 20, 15, '2026-02-14');


--Part 3
---3.1

create table users(
    user_id      integer,
    username     text,
    email        text,
    create_at    timestamp,
    unique (username),
    unique (email)
);

---3.2

create table course_enrollments(
    enrollment_id integer,
    student_id    integer,
    course_code   text,
    semester      text,
    unique (student_id, course_code, semester)
);

---3.3

alter table users add constraint unique_username unique (username);
alter table users add constraint unique_email unique (email);

insert into users values (1, 'arai', 'arai@mail.com', '2026-01-01');
insert into users values (2, 'sanzhar', 'sanzhar@mail.com', '2026-01-02');


--Part 4
---4.1

create table departments(
    dept_id    integer primary key,
    dept_name  text not null,
    location   text
);

insert into departments values (1, 'IT', 'A');
insert into departments values (2, 'HR', 'B');
insert into departments values (3, 'Sales', 'C');


---4.2

create table student_courses(
    student_id       integer,
    course_id        integer,
    enrollment_date  date,
    grade            text,
    primary key (student_id, course_id)
);

---4.3

-- 1) PRIMARY KEY = UNIQUE + NOT NULL. UNIQUE allows NULL
-- 2) Single column PK when one column identifies the row. composite PK when several columns together identify the row
-- 3) One PRIMARY KEY per table. many UNIQUE constraints are allowed


--Part 5
---5.1

create table employees_dept(
    emp_id     integer primary key,
    emp_name   text not null,
    dept_id    integer references departments,
    hire_date  date
);

insert into employees_dept values (1, 'Arai', 1, '2025-06-01');
insert into employees_dept values (2, 'Sanzhar', 2, '2025-08-15');


---5.2

create table authors(
    author_id    integer primary key,
    author_name  text not null,
    country      text
);

create table publishers(
    publisher_id    integer primary key,
    publisher_name  text not null,
    city            text
);

create table books(
    book_id           integer primary key,
    title             text not null,
    author_id         integer references authors,
    publisher_id      integer references publishers,
    publication_year  integer,
    isbn              text unique
);

insert into authors values (1, 'Author One', 'KZ');
insert into authors values (2, 'Author Two', 'USA');
insert into authors values (3, 'Author Three', 'UK');

insert into publishers values (1, 'Pub One', 'Almaty');
insert into publishers values (2, 'Pub Two', 'Astana');
insert into publishers values (3, 'Pub Three', 'London');

insert into books values (1, 'Book One', 1, 1, 2020, '111');
insert into books values (2, 'Book Two', 2, 2, 2021, '222');
insert into books values (3, 'Book Three', 3, 1, 2022, '333');

---5.3

create table categories(
    category_id    integer primary key,
    category_name  text not null
);

create table products_fk(
    product_id    integer primary key,
    product_name  text not null,
    category_id   integer references categories on delete restrict
);

create table orders(
    order_id    integer primary key,
    order_date  date not null
);

create table order_items(
    item_id     integer primary key,
    order_id    integer references orders on delete cascade,
    product_id  integer references products_fk,
    quantity    integer check(quantity > 0)
);

insert into categories values (1, 'Tech');
insert into categories values (2, 'Books');

insert into products_fk values (1, 'Phone', 1);
insert into products_fk values (2, 'Book', 2);

insert into orders values (1, '2026-04-01');
insert into orders values (2, '2026-04-02');

insert into order_items values (1, 1, 1, 2);
insert into order_items values (2, 1, 2, 1);
insert into order_items values (3, 2, 1, 1);

delete from orders where order_id = 1;


--Part 6
---6.1

drop table if exists order_items cascade;
drop table if exists orders cascade;
drop table if exists customers cascade;

create table customers(
    customer_id        integer primary key,
    name               text not null,
    email              text not null unique,
    phone              text,
    registration_date  date not null
);

create table products(
    product_id      integer primary key,
    name            text not null,
    description     text,
    price           numeric not null check(price >= 0),
    stock_quantity  integer not null check(stock_quantity >= 0)
);

create table orders(
    order_id      integer primary key,
    customer_id   integer not null references customers on delete restrict,
    order_date    date not null,
    total_amount  numeric not null check(total_amount >= 0),
    status        text not null check(
        status = 'pending'
        or status = 'processing'
        or status = 'shipped'
        or status = 'delivered'
        or status = 'cancelled'
        )
);

create table order_details(
    order_detail_id  integer primary key,
    order_id         integer not null references orders on delete cascade,
    product_id       integer not null references products on delete restrict,
    quantity         integer not null check(quantity > 0),
    unit_price       numeric not null check(unit_price >= 0)
);

insert into customers values
    (1, 'Arai', 'arai@gmail.com', '87075131103', '2026-01-05'),
    (2, 'Sanzhar', 'sanzhar@gmail.com', '87072001512', '2026-01-10'),
    (3, 'Omar', 'omar@gmail.com', null, '2026-01-15'),
    (4, 'Dana', 'dana@gmail.com', '87001110004', '2026-02-01'),
    (5, 'Ali', 'ali@gmail.com', '87001110005', '2026-02-12');

insert into products values
    (1, 'Mouse', 'black', 20, 100),
    (2, 'USB', 'short', 10, 50),
    (3, 'Lamp', 'desk', 30, 40),
    (4, 'Phone', 'android', 100, 20),
    (5, 'Bag', 'bag', 50, 15);

insert into orders values
    (1, 1, '2026-03-01', 20, 'pending'),
    (2, 2, '2026-03-02', 30, 'processing'),
    (3, 3, '2026-03-03', 100, 'shipped'),
    (4, 4, '2026-03-04', 50, 'delivered'),
    (5, 5, '2026-03-05', 10, 'cancelled');

insert into order_details values
    (1, 1, 1, 1, 20),
    (2, 2, 2, 3, 10),
    (3, 3, 4, 1, 100),
    (4, 4, 5, 1, 50),
    (5, 5, 2, 1, 10);
