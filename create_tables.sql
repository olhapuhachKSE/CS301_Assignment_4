create table customers (
    customer_id int generated always as identity primary key,
    customer_age int not null,
    customer_email varchar(100) unique not null,
    created_at timestamp default now()
    
    
);

create table customer_profiles (
    customer_id int primary key,
    full_name varchar(100) not null,
    phone varchar(30) not null,
    gender varchar(10) not null,

    foreign key (customer_id) references customers(customer_id)
);


create table genres (
    genre_id int generated always as identity primary key,
    genre_name varchar(50) unique not null
);


create table movies (
    movie_id int generated always as identity primary key,
    title varchar(150) not null,
    genre_id int not null,
    movie_age_rating varchar(10) not null,
    movie_rating numeric(2,1) not null,

    foreign key (genre_id) references genres(genre_id)
);

create table cinemas (
    cinema_id int generated always as identity primary key,
    cinema_name varchar(100) not null,
    cinema_city varchar(50) not null,
    employees_count int not null
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
    discount_name varchar(100) not null,
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
    rating numeric(2,1) check (rating >=0 and rating<=5) not null,
    review_text text,
    created_at timestamp,

    foreign key (customer_id) references customers(customer_id),
   
    foreign key (movie_id) references movies(movie_id)
);