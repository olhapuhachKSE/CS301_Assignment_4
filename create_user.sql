-- касир

create role shop_assistant login password 'qwerty1234';
grant select on movies, sessions, halls, discounts to shop_assistant;
grant select, insert, update on tickets, payments to shop_assistant;

-- локальний менеджер кінотеатру

create role local_manager login password 'localman1234';
grant select on  genres, movies, cinemas, halls, sessions, tickets, payments, discounts, ticket_discounts, reviews to local_manager;
grant update (employees_count) on cinemas to local_manager;

--глобальний менеджер по кінотеатрам

create role global_manager login password 'globman9876'
grant select on customer_profiles, genres, movies, cinemas, halls, sessions, tickets, payments, discounts, ticket_discounts, reviews to global_manager;
grant select, insert, update on genres, movies, cinemas, halls, sessions, discounts, reviews to global_manager;
