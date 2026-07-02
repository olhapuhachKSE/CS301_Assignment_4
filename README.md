# CS301_Practical_Assignment_4

I created an operational PostgreSQL database for managing a cinema network.

The goal of this assignment is to practice:

- database design
- relationships (1:1, 1:many, many:many)
- constraints
- indexes and query optimization
- EXPLAIN ANALYZE
- SQL views
- SQL stored procedures
- SQL triggers and functions
- users, roles and privileges

## Created tables

- customers – stores customer information
- customer_profiles – stores additional customer details
- genres – stores movie genres
- movies – stores movie information
- cinemas – stores cinema information
- halls – stores cinema halls
- sessions – stores movie sessions
- tickets – stores purchased tickets
- payments – stores payment information
- discounts – stores available discounts
- ticket_discounts – many-to-many relationship between tickets and discounts
- reviews – stores customer reviews for movies
  

## Database features

- Primary keys and foreign keys
- One-to-one, one-to-many and many-to-many relationships
    - One-to-one relationship (customers ↔ customer_profiles)
    - One-to-many relationships (genres → movies, cinemas → halls, movies → sessions, halls → sessions, customers → tickets, sessions → tickets, tickets → payments, customers → reviews, movies → reviews)
    - Many-to-many relationship (tickets ↔ discounts through ticket_discounts)
- Constraints (PRIMARY KEY, FOREIGN KEY, UNIQUE, CHECK)
- Indexes for query optimization
- Query performance comparison using EXPLAIN ANALYZE
- SQL View for displaying movie reviews with rating greater than 4
- Stored procedure for updating session price
- Trigger and function for automatically updating the number of movies in each genre
- Three database users with different privileges:
  - Cashier
  - Local cinema manager
  - Global manager

### Database Schema

This is the database schema for the project.

This is the ERD:

```mermaid
erDiagram

    CUSTOMERS {
        INT customer_id PK
        INT customer_age
        VARCHAR customer_email
        TIMESTAMP created_at
    }

    CUSTOMER_PROFILES {
        INT customer_id PK
        VARCHAR full_name
        VARCHAR phone
        VARCHAR gender
    }

    GENRES {
        INT genre_id PK
        VARCHAR genre_name
        INT movie_count
    }

    MOVIES {
        INT movie_id PK
        INT genre_id
        VARCHAR title
        VARCHAR movie_age_rating
        NUMERIC movie_rating
    }

    CINEMAS {
        INT cinema_id PK
        VARCHAR cinema_name
        VARCHAR cinema_city
        INT employees_count
    }

    HALLS {
        INT hall_id PK
        INT cinema_id
        INT hall_number
        INT capacity
    }

    SESSIONS {
        INT session_id PK
        INT movie_id
        INT hall_id
        TIMESTAMP session_time
        NUMERIC price
    }

    TICKETS {
        INT ticket_id PK
        INT customer_id
        INT session_id
        INT quantity
    }

    PAYMENTS {
        INT payment_id PK
        INT ticket_id
        NUMERIC amount
        VARCHAR payment_method
        VARCHAR payment_status
        TIMESTAMP payment_last_update_time
    }

    DISCOUNTS {
        INT discount_id PK
        VARCHAR discount_name
        NUMERIC discount_percent
        TEXT description
    }

    TICKET_DISCOUNTS {
        INT ticket_id
        INT discount_id
    }

    REVIEWS {
        INT review_id PK
        INT customer_id
        INT movie_id
        NUMERIC rating
        TEXT review_text
        TIMESTAMP created_at
    }

    CUSTOMERS ||--|| CUSTOMER_PROFILES : has

    GENRES ||--o{ MOVIES : contains

    CINEMAS ||--o{ HALLS : contains

    MOVIES ||--o{ SESSIONS : has

    HALLS ||--o{ SESSIONS : hosts

    CUSTOMERS ||--o{ TICKETS : purchases

    SESSIONS ||--o{ TICKETS : includes

    TICKETS ||--|| PAYMENTS : payment

    TICKETS ||--o{ TICKET_DISCOUNTS : has

    DISCOUNTS ||--o{ TICKET_DISCOUNTS : applies

    CUSTOMERS ||--o{ REVIEWS : writes

    MOVIES ||--o{ REVIEWS : receives
```
