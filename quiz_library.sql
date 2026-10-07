-- Setup for In-Class Task: Library (run before the task)
DROP TABLE IF EXISTS loans;
DROP TABLE IF EXISTS books;

CREATE TABLE books (
    book_id SERIAL PRIMARY KEY,
    title   VARCHAR(100),
    genre   VARCHAR(20) DEFAULT 'General',
    price   NUMERIC(8,2),
    copies  INTEGER DEFAULT 1,
    status  VARCHAR(15) DEFAULT 'Available'
);

CREATE TABLE loans (
    loan_id     SERIAL PRIMARY KEY,
    book_id     INTEGER,
    member_name VARCHAR(50),
    loan_date   DATE,
    return_date DATE
);

INSERT INTO books (title, genre, price, copies) VALUES
    ('Database Systems',     'Science', 12000.00, 4),
    ('Clean Code',           'Science',  9500.00, 2),
    ('Abai Zholy',           'Fiction',  6000.00, 5),
    ('The Little Prince',    'Fiction',  3500.00, 0),
    ('History of the Steppe','History',  7000.00, 1),
    ('Linear Algebra',       'Science',  8000.00, 3);

INSERT INTO loans (book_id, member_name, loan_date, return_date) VALUES
    (1,    'Aruzhan', '2026-09-01', '2026-09-15'),
    (1,    'Dias',    '2026-09-10', NULL),
    (3,    'Madina',  '2026-09-12', NULL),
    (2,    'Timur',   '2026-08-20', '2026-09-05'),
    (NULL, 'Guest',   '2026-09-20', NULL);



--TASK 1
INSERT INTO books (title , genre, price,  copies)
VALUES ('Python Basics', DEFAULT, 420000, DEFAULT)

RETURNING ;

--TASK 2
UPDATE books
SET price = PRICE * 1.15
WHERE genre == 'Science'
AND copies > 2
RETURNING title, price;

--TASK 3
UPDATE books
SET STATUS == CASE
    WHEN COPIES = 0 THEN 'Out'
     WHEN COPIES BETWEEN 1 AND 2 THEN 'Limited'
    ELSE 'Available'
END;

--TASK 4
UPDATE books
SET COPIES
    )


--TASK 5
DELETE FROM books WHERE book_id NOT IN (
    SELECT book_id
    FROM loans
        WHERE book_id IS NOT NULL
    )
RETURNING book_id, title;

