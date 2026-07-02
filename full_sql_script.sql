
create table customers (
    customer_id int generated always as identity primary key,
    customer_age int not null,
    customer_email varchar(100) unique not null,
    created_at timestamp default now()
);

create table customer_profiles (
    customer_id int primary key,
    full_name varchar(100) not null,
    phone varchar(30),
    gender varchar(10),

    foreign key (customer_id) references customers(customer_id)
);


create table genres (
    genre_id int generated always as identity primary key,
    genre_name varchar(50) unique not null
);


create table movies (
    movie_id int generated always as identity primary key,
    title varchar(150) not null,
    genre_id int,
    movie_age_rating varchar(10),
    movie_rating numeric(2,1),

    foreign key (genre_id) references genres(genre_id)
);

create table cinemas (
    cinema_id int generated always as identity primary key,
    cinema_name varchar(100),
    cinema_city varchar(50),
    employees_count int
);


create table halls (
    hall_id int generated always as identity primary key,
    cinema_id int not null,
    hall_number int not null,
    capacity int not null,

    foreign key (cinema_id) references cinemas(cinema_id)
);


create table sessions (
    session_id int generated always as identity primary key,
    movie_id int not null,
    hall_id int not null,
    session_time timestamp not null,
    price numeric(6,2) not null,

    foreign key (movie_id) references movies(movie_id),

    foreign key (hall_id) references halls(hall_id)
);


create table tickets (
    ticket_id int generated always as identity primary key,
    customer_id int not null,
    session_id int not null,
    quantity int not null default 1,

    foreign key (customer_id) references customers(customer_id),

    foreign key (session_id) references sessions(session_id)
);


create table payments (
    payment_id int generated always as identity primary key,
    ticket_id int unique not null,
    amount numeric(8,2) not null,
    payment_method varchar(20) not null,
    payment_status varchar(20) not null,
    payment_last_apdate_time timestamp not null,

    foreign key (ticket_id) references tickets(ticket_id)
);


create table discounts (
    discount_id int generated always as identity primary key,
    discount_name varchar(100),
    discount_percent numeric(5,2) not null,
    description text
);

--проміжна табл одна знижка може бути у багатьох квитків і один квиток може мати декілька знижок
create table ticket_discounts (
    ticket_id int not null,
    discount_id int not null,

    primary key (ticket_id, discount_id),

    foreign key (ticket_id) references tickets(ticket_id),

    foreign key (discount_id) references discounts(discount_id)
);


create table reviews (
    review_id int generated always as identity primary key,
    customer_id int not null,
    movie_id int not null,
    rating numeric(2,1) check (rating >=0 and rating<=5),
    review_text text,
    created_at timestamp,

    foreign key (customer_id) references customers(customer_id),

    foreign key (movie_id) references movies(movie_id)
);



-- Запит для аналізу (показує кількість кастомерів зі студентською знижкою)

explain analyze
select
	count(distinct t.customer_id) as cust_with_student_disc
	-- distimct дістає тільки унікальні
from tickets t
join ticket_discounts td
	on t.ticket_id = td.ticket_id
join discounts d
	on td.discount_id = d.discount_id
where d.discount_name = 'Student';


-- індекс для таблиці знижки писати не логічно там всього 4 рядки програмі простіше повністю прочитата ніж створювати тут індекси

CREATE INDEX idx_ticket_discounts_composite ON ticket_discounts(discount_id, ticket_id);
-- коли програма знаходить що ід знижки студента = 1 вона починає шукати квитки з таким ід для знижки
-- тому ставимо індекс на таблицю ticket_discounts де першим чином шукається ід знижки по ним вже знаходимо ід потрібного квитка




-- касир

create role shop_assistant login password 'qwerty1234';
grant select on movies to shop_assistant;
grant select on sessions to shop_assistant;
grant select on halls to shop_assistant;
grant select on discounts to shop_assistant;
grant select, insert, update on tickets to shop_assistant;
grant select, insert, update on payments to shop_assistant;


-- локальний менеджер кінотеатру

create role local_manager login password 'localman1234';
grant select on  genres, movies, cinemas, halls, sessions, tickets, payments, discounts, ticket_discounts, reviews to local_manager;
grant update (employees_count) on cinemas to local_manager;


--глобальний менеджер по кінотеатрам

create role global_manager login password 'globman9876'
grant select on customer_profiles, genres, movies, cinemas, halls, sessions, tickets, payments, discounts, ticket_discounts, reviews to global_manager;
grant select, insert, update on genres, movies, cinemas, halls, sessions, discounts, reviews to global_manager;



create view reviews_view
as
select rating, movie_id
from reviews
where rating > 4;

-- перевірка
select * from reviews_view;



create or replace procedure change_price (new_session_id int, new_price numeric)
language plpgsql
as
$$
begin
	update sessions
	set price = new_price
	where session_id = new_session_id;
end;
$$;

call change_price(1, 1000)

-- перевірка чи змінилось значення
select
    session_id,
    price
from sessions
where session_id = 1;




-- створення тригеру
alter table genres
add column movie_count int default 0;
-- щоб не було налл

create or replace function fnc_ganre_movie_count()
returns trigger
language plpgsql
as
$$
begin
	update genres
	set movie_count = (select count(*)
		from movies
		where genre_id = new.genre_id)
	where genre_id = new.genre_id;
	return new;
end;
$$;


create trigger trg_update_genre_count
after insert on movies
for each row
execute function fnc_ganre_movie_count();

-- перевірка
insert into movies (title, genre_id, movie_age_rating, movie_rating)
values ('Test movie', 1, '16+', 4.5);

-- так кількість змінилась
select *
from genres;








