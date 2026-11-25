create database lab_9;
\c lab_9;

--part 1

drop table if exists rentals, bikes, members, stations cascade;

create table stations (
    station_id   int primary key,
    station_name varchar(50) not null,
    city         varchar(40) not null,
    capacity     int not null
);

create table bikes (
    bike_id    int primary key,
    model      varchar(50) not null,
    station_id int references stations(station_id),
    daily_rate numeric(8,2) not null
);

create table members (
    member_id int primary key,
    full_name varchar(60) not null,
    city      varchar(40) not null,
    joined_on date not null
);

create table rentals (
    rental_id  int primary key,
    member_id  int references members(member_id),
    bike_id    int references bikes(bike_id),
    start_date date not null,
    end_date   date,
    fee        numeric(8,2)
);

insert into stations values
 (10, 'Central Park', 'Almaty',   4),
 (20, 'Riverside',    'Almaty',   3),
 (30, 'Expo Gate',    'Astana',   5),
 (40, 'Old Town',     'Shymkent', 2),
 (50, 'Depot',        'Astana',   0);

insert into bikes values
 (101, 'City Cruiser', 10,  4.50),
 (102, 'City Cruiser', 10,  4.50),
 (103, 'Mountain X',   20,  7.00),
 (104, 'Mountain X',   30,  7.00),
 (105, 'Road Sprint',  30,  9.25),
 (106, 'Folding Mini', 40,  3.75),
 (107, 'Cargo Hauler', 20, 12.00),
 (108, 'Road Sprint',  10,  9.25);

insert into members values
 (1, 'Aisha Nurlanova', 'Almaty',   date '2023-03-14'),
 (2, 'Daniyar Serik',   'Almaty',   date '2023-07-02'),
 (3, 'Marta Kowalski',  'Astana',   date '2024-01-20'),
 (4, 'Chen Wei',        'Astana',   date '2024-05-11'),
 (5, 'Omar Haddad',     'Shymkent', date '2024-09-30'),
 (6, 'Elena Petrova',   'Almaty',   date '2025-02-05');

insert into rentals values
 ( 1, 1, 101, date '2024-04-05', date '2024-04-08', 13.50),
 ( 2, 1, 103, date '2024-06-11', date '2024-06-16', 35.00),
 ( 3, 1, 108, date '2025-02-02', date '2025-02-04', 18.50),
 ( 4, 1, 102, date '2025-05-20', date '2025-05-27', 31.50),
 ( 5, 2, 101, date '2024-05-01', date '2024-05-02',  4.50),
 ( 6, 2, 107, date '2024-11-15', date '2024-11-19', 48.00),
 ( 7, 2, 107, date '2025-03-08', date '2025-03-14', 72.00),
 ( 8, 3, 104, date '2024-02-14', date '2024-02-18', 28.00),
 ( 9, 3, 105, date '2024-08-03', date '2024-08-06', 27.75),
 (10, 3, 104, date '2025-01-09', date '2025-01-10',  7.00),
 (11, 3, 105, date '2025-06-01', date '2025-06-09', 74.00),
 (12, 4, 104, date '2024-07-19', date '2024-07-21', 14.00),
 (13, 4, 105, date '2025-04-12', date '2025-04-15', 27.75),
 (14, 4, 103, date '2025-07-23', date '2025-07-29', 42.00),
 (15, 5, 106, date '2024-10-05', date '2024-10-12', 26.25),
 (16, 5, 106, date '2025-01-18', date '2025-01-20',  7.50),
 (17, 5, 106, date '2025-08-14', date '2025-08-21', 26.25),
 (18, 2, 102, date '2025-09-02', date '2025-09-05', 13.50),
 (19, 1, 101, date '2025-10-10', null,              null),
 (20, 4, 108, date '2024-12-28', date '2025-01-03', 55.50),
 (21, 3, 103, date '2025-02-26', date '2025-03-02', 28.00),
 (22, 5, 104, date '2025-05-05', date '2025-05-08', 21.00);

select
    (select count(*) from stations) as stations,
    (select count(*) from bikes) as bikes,
    (select count(*) from members) as members,
    (select count(*) from rentals) as rentals;


--part 2

---2.1
create or replace function rental_days(p_rental_id int)
returns int as $$
declare
    days int;
begin
    select end_date - start_date
    into days
    from rentals
    where rental_id = p_rental_id;
    return days;
end;
$$ language plpgsql;

select rental_days(2);
select rental_days(11);
select rental_days(19);
select rental_days(999);
-- A: both return null but not for the same reason for 19 end_date is null so end_date - start_date is null for 999 there is no row so select into leaves the variable null

---2.2
create or replace function member_rental_count(p_member_id int)
returns int as $$
declare
    cnt int;
begin
    select count(*)
    into cnt
    from rentals
    where member_id = p_member_id;
    return cnt;
end;
$$ language plpgsql;

select member_rental_count(1);
select member_rental_count(5);
select member_rental_count(6);
select member_rental_count(99);
-- A: count always counts rows that match the where if nobody matches it still returns 0 not null so a real member with zero rentals and a fake id look the same

---2.3
create or replace function station_city(p_station_id int)
returns varchar as $$
declare
    city_name varchar;
begin
    select city
    into city_name
    from stations
    where station_id = p_station_id;
    return city_name;
end;
$$ language plpgsql;

select station_city(30);
select station_city(77);

---2.4
select rental_id, member_id, rental_days(rental_id) as days
from rentals
where rental_days(rental_id) > 4
order by days desc;


--part 3

---3.1
create or replace function fee_with_discount(p_fee numeric, p_percent numeric)
returns numeric as $$
begin
    return round(p_fee * (1 - p_percent / 100), 2);
end;
$$ language plpgsql;

select fee_with_discount(74.00, 15);

---3.2
create or replace function member_stats(
    p_member_id int,
    out rental_cnt int,
    out total_fee numeric,
    out last_start date
) as $$
begin
    select count(*), coalesce(sum(fee), 0), max(start_date)
    into rental_cnt, total_fee, last_start
    from rentals
    where member_id = p_member_id;
end;
$$ language plpgsql;

select member_stats(3);
select * from member_stats(3);
select * from member_stats(6);
-- A: select member_stats(3) gives one composite value select * from member_stats(3) gives three columns i would use the from form in a bigger query because columns are easy to join for member 6 i get 0 and 0 and null

---3.3
create or replace function apply_late_fee(inout p_fee numeric) as $$
begin
    p_fee := p_fee + 5.00;
end;
$$ language plpgsql;

select apply_late_fee(fee) from rentals where rental_id = 1;
-- A: inout is both input and output so the changed p_fee is sent back automatically

---3.4
create or replace function fee_summary(
    variadic p_fees numeric[],
    out total numeric,
    out average numeric,
    out largest numeric
) as $$
begin
    select sum(p_fees[i]), round(avg(p_fees[i]), 2), max(p_fees[i])
    into total, average, largest
    from generate_subscripts(p_fees, 1) g(i);
end;
$$ language plpgsql;

select * from fee_summary(13.50, 35.00, 18.50, 31.50);
-- A: it runs with an empty array so total average and largest come out null variadic must be last because postgres packs leftover args into that array and would not know where the next param starts if something came after it

---3.5
-- (a) in - only need the id to look up a row
-- (b) inout - caller gives a balance and wants the updated one back
-- (c) variadic - unknown how many station ids will be passed
-- (d) out - two stats come out together from one pass


--part 4

---4.1
create or replace function total_fees(p_member_id int)
returns numeric as $$
declare
    s numeric;
begin
    select coalesce(sum(fee), 0)
    into s
    from rentals
    where member_id = p_member_id;
    return s;
end;
$$ language plpgsql;

select total_fees(1);
select total_fees(6);

---4.2
create or replace function total_fees(p_member_id int, p_from_date date)
returns numeric as $$
declare
    s numeric;
begin
    select coalesce(sum(fee), 0)
    into s
    from rentals
    where member_id = p_member_id
      and start_date >= p_from_date;
    return s;
end;
$$ language plpgsql;

select total_fees(1, date '2024-01-01');
select total_fees(1, date '2025-01-01');

select proname, pg_get_function_identity_arguments(oid) as args
from pg_proc
where proname = 'total_fees';

---4.3
create or replace function total_fees(
    p_member_id int,
    p_from_date date default date '2025-01-01'
)
returns numeric as $$
declare
    s numeric;
begin
    select coalesce(sum(fee), 0)
    into s
    from rentals
    where member_id = p_member_id
      and start_date >= p_from_date;
    return s;
end;
$$ language plpgsql;

-- select total_fees(1);
-- error:  function total_fees(integer) is not unique
-- line 1: select total_fees(1);
--                ^
-- A: both the one-arg total_fees(int) and the two-arg with default match a call with one int so postgres does not know which to pick

---4.4
drop function total_fees(integer);

select total_fees(1);
-- A: the version with default from_date answers now and returns 50.00 for member 1 from 2025 only if i dropped the other version instead the plain one-arg would return all fees 98.50 so not the same

---4.5
create or replace function total_fees(p_full_name varchar)
returns numeric as $$
declare
    s numeric;
begin
    select coalesce(sum(r.fee), 0)
    into s
    from members m
    join rentals r on r.member_id = m.member_id
    where m.full_name = p_full_name;
    return s;
end;
$$ language plpgsql;

select total_fees('Aisha Nurlanova');
select total_fees(1);
-- A: varchar and int are different types so the call is not ambiguous total_fees with the name uses the varchar version and sums all fees total_fees(1) uses the int plus default date version so only fees from 2025


--part 5

---5.1
create or replace function find_bikes(p_pattern varchar)
returns table (found_id int, found_model varchar, found_rate numeric) as $$
begin
    return query
    select bike_id, model, daily_rate
    from bikes
    where model ilike p_pattern
    order by bike_id;
end;
$$ language plpgsql;

select * from find_bikes('%road%');
select * from find_bikes('%Mini');
select find_bikes('%road%');
-- A: without from each row becomes one composite value in a single column with from i get normal columns

---5.2
create or replace function member_history(p_member_id int)
returns table (
    out_rental_id int,
    out_model varchar,
    out_station varchar,
    out_days int,
    out_fee numeric
) as $$
begin
    return query
    select
        r.rental_id,
        b.model,
        s.station_name,
        (r.end_date - r.start_date),
        r.fee
    from rentals r
    join bikes b on b.bike_id = r.bike_id
    join stations s on s.station_id = b.station_id
    where r.member_id = p_member_id
    order by r.start_date;
end;
$$ language plpgsql;

select * from member_history(3);

---5.3
-- broken version (create works call fails):
-- same function but returns table (bike_id int, model varchar)
-- and select bike_id, model from bikes without table alias
-- select * from bike_list(10);
-- error:  column reference "bike_id" is ambiguous
-- detail:  It could refer to either a PL/pgSQL variable or a table column.
-- query:  select bike_id, model from bikes where station_id = p_station_id
-- context:  PL/pgSQL function bike_list(integer) line 3 at RETURN QUERY
-- A: create only checks syntax the names collide when the body really runs because returns table makes bike_id and model variables

-- fix 1
create or replace function bike_list(p_station_id int)
returns table (out_bike_id int, out_model varchar) as $$
begin
    return query
    select bike_id, model
    from bikes
    where station_id = p_station_id;
end;
$$ language plpgsql;

select * from bike_list(10);

-- fix 2
drop function if exists bike_list(integer);
create or replace function bike_list(p_station_id int)
returns table (bike_id int, model varchar) as $$
begin
    return query
    select b.bike_id, b.model
    from bikes b
    where b.station_id = p_station_id;
end;
$$ language plpgsql;

select * from bike_list(10);

---5.4
create or replace function station_board(p_city varchar)
returns table (s_name varchar, s_bikes int, s_free int) as $$
begin
    return query
    select
        s.station_name,
        count(b.bike_id)::int,
        (s.capacity - count(b.bike_id))::int
    from stations s
    left join bikes b on b.station_id = s.station_id
    where s.city = p_city
    group by s.station_id, s.station_name, s.capacity;
end;
$$ language plpgsql;

select * from station_board('Almaty');
-- without cast: count(b.bike_id) left as bigint instead of ::int
-- select * from station_board('Almaty');
-- error:  structure of query does not match function result type
-- detail:  Returned type bigint does not match expected type integer in column 2.
-- context:  pl/pgSQL function station_board(character varying) line 3 at RETURN QUERY


--part 6

---6.1
do $$
<<rental_report>>
declare
    total_rentals integer := 0;
begin
    select count(*) into total_rentals from rentals;
    raise notice 'The rentals table holds % rows', total_rentals;
end rental_report;
$$;
-- if end label does not match:
-- end wrong_label;
-- error:  END label "wrong_label" differs from block's label "rental_report"
-- context:  compilation of PL/pgSQL function "inline_code_block" near line ...
-- A: postgres raises an error that the end label does not match the block label

---6.2
do $$
<<rental_report>>
declare
    total_rentals integer := 0;
    fee_total numeric;
begin
    select count(*) into total_rentals from rentals;
    raise notice 'The rentals table holds % rows', total_rentals;

    select coalesce(sum(fee), 0) into fee_total from rentals;
    raise notice 'outer before subblock: %', fee_total;

    declare
        fee_total numeric;
    begin
        select coalesce(sum(fee), 0)
        into fee_total
        from rentals
        where start_date >= date '2025-01-01';
        raise notice 'subblock value: %', fee_total;
        raise notice 'outer via label: %', rental_report.fee_total;
    end;

    raise notice 'outer after subblock: %', fee_total;
end rental_report;
$$;
-- A: 621.50 then 369.00 then 621.50 then 621.50 the subblock did not change the outer variable so a declaration in a subblock is local and only hides the outer name inside that subblock

---6.3
-- try to read a variable from the first subblock in a second one
-- first subblock declares hidden_val second subblock tries to raise notice it
-- error:  column "hidden_val" does not exist
-- line ...: raise notice %, hidden_val;
-- query:  RAISE NOTICE %, hidden_val
-- context:  pl/pgSQL function inline_code_block line ... at RAISE

do $$
<<outer_blk>>
declare
    shared_val int := 1;
begin
    declare
    begin
        raise notice 'first subblock sees %', shared_val;
    end;

    declare
    begin
        raise notice 'second subblock sees %', shared_val;
    end;
end outer_blk;
$$;

---6.4
create or replace function fee_split(
    p_from_date date,
    out before_total numeric,
    out after_total numeric
) as $$
begin
    select coalesce(sum(fee), 0)
    into before_total
    from rentals
    where start_date < p_from_date;

    select coalesce(sum(fee), 0)
    into after_total
    from rentals
    where start_date >= p_from_date;
end;
$$ language plpgsql;

select * from fee_split(date '2025-01-01');
select before_total + after_total as check_sum,
       (select coalesce(sum(fee), 0) from rentals) as table_total
from fee_split(date '2025-01-01');


--part 7

---7.1
create or replace function station_load(
    p_station_id int,
    out bikes_parked int,
    out capacity_pct numeric
) as $$
declare
    cap int;
begin
    select capacity into cap
    from stations
    where station_id = p_station_id;

    select count(*)::int into bikes_parked
    from bikes
    where station_id = p_station_id;

    if cap is null then
        capacity_pct := null;
    elsif cap = 0 then
        capacity_pct := null;
    else
        capacity_pct := round(bikes_parked * 100.0 / cap, 1);
    end if;
end;
$$ language plpgsql;

select s.station_id, s.station_name, l.*
from stations s, lateral station_load(s.station_id) l;

---7.2
create or replace function top_members(p_limit int default 3)
returns table (
    member_name varchar,
    rental_cnt bigint,
    total_spent numeric
) as $$
begin
    return query
    select
        m.full_name,
        count(r.rental_id),
        coalesce(sum(r.fee), 0)
    from members m
    left join rentals r on r.member_id = m.member_id
    group by m.member_id, m.full_name
    order by coalesce(sum(r.fee), 0) desc
    limit p_limit;
end;
$$ language plpgsql;

select * from top_members();
select * from top_members(6);
-- A: aisha has more rentals than chen and daniyar but less money spent ranking is by amount spent so that is expected

---7.3
create or replace function rental_invoice(p_rental_id int)
returns table (
    member_name varchar,
    bike_model varchar,
    days int,
    amount_owed numeric,
    status text
) as $$
begin
    return query
    select
        m.full_name,
        b.model,
        (coalesce(r.end_date, current_date) - r.start_date),
        round(
            (coalesce(r.end_date, current_date) - r.start_date) * b.daily_rate,
            2
        ),
        case when r.end_date is null then 'OPEN' else 'CLOSED' end
    from rentals r
    join members m on m.member_id = r.member_id
    join bikes b on b.bike_id = r.bike_id
    where r.rental_id = p_rental_id;
end;
$$ language plpgsql;

select * from rental_invoice(11);
select * from rental_invoice(19);
-- A: for rental 11 yes 74 equals the stored fee for rental 19 days go up to current_date so the amount changes every day a function that uses current_date cannot be immutable because the result is not fixed for the same args

---7.4
create or replace function city_report(p_city varchar)
returns table (
    member_cnt bigint,
    rental_cnt bigint,
    total_revenue numeric
) as $$
begin
    return query
    select
        count(distinct m.member_id),
        count(r.rental_id),
        coalesce(sum(r.fee), 0)
    from members m
    left join rentals r on r.member_id = m.member_id
    where m.city = p_city;
end;
$$ language plpgsql;

create or replace function city_report(p_city varchar, p_from_date date)
returns table (
    member_cnt bigint,
    rental_cnt bigint,
    total_revenue numeric
) as $$
begin
    return query
    select
        count(distinct m.member_id),
        count(r.rental_id),
        coalesce(sum(r.fee), 0)
    from members m
    left join rentals r
      on r.member_id = m.member_id
     and r.start_date >= p_from_date
    where m.city = p_city;
end;
$$ language plpgsql;

select * from city_report('Almaty');
select * from city_report('Almaty', date '2025-01-01');

-- date in WHERE instead of ON (wrong for keeping members):
-- select count(distinct m.member_id)
-- from members m
-- left join rentals r on r.member_id = m.member_id
-- where m.city = 'Almaty' and r.start_date >= date '2025-01-01';
-- A: with the date in on almaty still counts all 3 members including elena with the date in where members who have no matching rental drop out so the member count gets smaller


--lab questions
-- 1) the name is just total_fees the signature is name plus argument types postgres needs the signature to drop one overloaded version without removing the others
-- 2) dollar quoting lets you write quotes inside the body without doubling them example with doubled quotes is awkward dollar quotes make it simple
-- 3) out params are good for a few fixed values from one call returns table is better when you need many rows
-- 4) variadic packs leftover args so if it was not last a call like f(1 2 3 4) would not show where the list ends and the next param begins
-- 5) return sends one value and ends the function return query sends the rows of a select as the table result
-- 6) a default can make an old one-arg call match two functions at once avoid it by not giving defaults that clash with another overload or by renaming
-- 7) when the subblock ends its local variable is gone to read the outer shadowed one use the outer block label like outer.fee_total
-- 8) advantage: one place for the rule for every app disadvantage: harder to version and test than app code
-- 9) trusted cannot touch files or network so normal users can write it untrusted can so only a superuser may create those functions
-- 10) create or replace with different argument types does not replace the old one it adds another overload so both stay and callers may get the wrong one or an ambiguity error


--additional
---1
create or replace function busiest_station(p_from_date date default date '2024-01-01')
returns table (station_id int, station_name varchar, total_days int) as $$
begin
    return query
    select
        s.station_id,
        s.station_name,
        coalesce(sum(coalesce(r.end_date, current_date) - r.start_date), 0)::int as total_days
    from stations s
    join bikes b on b.station_id = s.station_id
    join rentals r on r.bike_id = b.bike_id
    where r.start_date >= p_from_date
    group by s.station_id, s.station_name
    order by total_days desc
    limit 1;
end;
$$ language plpgsql;

select * from busiest_station();

---2
do $$
declare
    rec record;
begin
    for rec in
        select m.full_name, count(r.rental_id) as cnt, coalesce(sum(r.fee), 0) as spent
        from members m
        left join rentals r on r.member_id = m.member_id
        group by m.member_id, m.full_name
        order by m.member_id
    loop
        raise notice '% rentals=% spent=%', rec.full_name, rec.cnt, rec.spent;
    end loop;
end;
$$;
-- a single select is clearer and faster for a report i would ship the select not the loop

---3
create or replace function rental_days(p_rental_id int)
returns int as $$
declare
    days int;
begin
    select end_date - start_date
    into days
    from rentals
    where rental_id = p_rental_id;

    if not found then
        raise exception 'unknown rental id: %', p_rental_id;
    end if;

    return days;
end;
$$ language plpgsql;
-- clearer for a direct call but worse inside a big query because one bad id aborts the whole select

---4
create or replace function fee_report(p_member_id int)
returns numeric as $$
begin
    return total_fees(p_member_id);
end;
$$ language plpgsql;

create or replace function fee_report(p_name varchar)
returns numeric as $$
begin
    return total_fees(p_name);
end;
$$ language plpgsql;

-- create or replace function fee_report(p_name text) ...
-- varchar and text are the same category so postgres may treat them as conflicting overloads and refuse or make calls ambiguous

---5
create or replace procedure close_rental(p_rental_id int, p_end date)
language plpgsql
as $$
declare
    rate numeric;
    started date;
begin
    select b.daily_rate, r.start_date
    into rate, started
    from rentals r
    join bikes b on b.bike_id = r.bike_id
    where r.rental_id = p_rental_id;

    update rentals
    set end_date = p_end,
        fee = round((p_end - started) * rate, 2)
    where rental_id = p_rental_id
      and end_date is null;
end;
$$;
-- call close_rental(19, current_date);
-- a procedure can do transaction control like commit/rollback in some cases and is meant for side effects while a function is meant to return a value
