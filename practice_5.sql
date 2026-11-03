-- Sample rows for In-Class Task: Online Shop, constraints (run after Task 3)
INSERT INTO customers (customer_id, full_name, email) VALUES
    (1, 'Aliya Nurova',  'aliya@mail.kz'),
    (2, 'Bauyrzhan Kim', 'baur@mail.kz'),
    (3, 'Dana Seitova',  'dana@mail.kz');

INSERT INTO orders (order_id, customer_id, order_date, status) VALUES
    (101, 1, '2026-10-01', 'shipped'),
    (102, 2, '2026-10-03', 'pending'),
    (103, 3, '2026-10-05', 'delivered');

INSERT INTO order_items (item_id, order_id, product, quantity) VALUES
    (1, 101, 'Keyboard', 2),
    (2, 101, 'Mouse',    1),
    (3, 103, 'Monitor',  1);



--Task 1

create table customers(
    customer_id    integer primary key,
    full_name      text not null,
    email          text not null unique
);


--Task 2

create table orders(
    order_id   integer primary key,
    customer_id  integer not null references customers on delete cascade,
    order_date   date not null,
    status    text not null default 'pending',
    constraint  valid_status check(
        status = 'pending'
        or status = 'processing'
        or status = 'shipped'
        or status = 'delivered'
        or status = 'cancelled'
        )
);


--Task 3

create table order_items(
    item_id   integer primary key,
    order_id   integer not null references  orders on delete restrict,
    product   text not null,
    quantity  integer not null default 0 check(quantity > 0)
);

--Task 4

--a. not null on status
--b. in valid_status shipped is not allowed
--c. check on quantity default 0
--d. ok
--e. on delete restrict 101 has item
--f. forein key
--g. ok
