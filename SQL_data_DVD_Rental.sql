SELECT c.first_name, c.last_name, SUM(p.amount) as total, MIN(p.payment_date), MAX(p.payment_date)
FROM payment as p, customer as c
WHERE c.customer_id = p.customer_id
GROUP BY c.first_name, c.last_name
ORDER BY SUM(p.amount) DESC;

SELECT c.first_name, c.last_name, f.title, SUM(p.amount) as Total
FROM payment p
JOIN customer c ON p.customer_id = c.customer_id
JOIN rental r ON p.rental_id = r.rental_id
JOIN inventory i ON r.inventory_id = i.inventory_id
JOIN film f ON i.film_id = f.film_id
GROUP BY c.first_name, c.last_name, f.film_id
ORDER BY SUM(p.amount) DESC;

SELECT  f.title, c.city, SUM(p.amount) as Total
FROM payment p
JOIN rental r ON p.rental_id = r.rental_id
JOIN inventory i ON r.inventory_id = i.inventory_id
JOIN film f ON i.film_id = f.film_id
JOIN staff s ON p.staff_id = s.staff_id
JOIN address a ON s.address_id = a.address_id
JOIN city c ON a.city_id = c.city_id
GROUP BY f.title, c.city
ORDER BY SUM(p.amount) DESC;

"Create tables as per Schema-Design"
CREATE TABLE dim_date
(
	date_key integer NOT NULL PRIMARY KEY,
	date date NOT NULL,
	year smallint NOT NULL,
	quarter smallint NOT NULL,
	month smallint NOT NULL,
	week smallint NOT NULL,
	day smallint NOT NULL,
	is_weekend boolean
);

CREATE TABLE dim_movie
(
	movie_key integer NOT NULL PRIMARY KEY,
	title VARCHAR(30) NOT NULL,
	description VARCHAR(250) NOT NULL,
	release_year smallint NOT NULL,
	language VARCHAR(30) NOT NULL,
	original_language VARCHAR NOT NULL,
	length smallint NOT NULL,
	rating VARCHAR(30),
	special_features VARCHAR(100) NOT NULL
);

CREATE TABLE dim_customer
(
	customer_key integer NOT NULL PRIMARY KEY,
	first_name VARCHAR(50) NOT NULL,
	last_name VARCHAR(50) NOT NULL,
	email VARCHAR(50),
	address VARCHAR(100) NOT NULL,
	address2 VARCHAR(100),
	district VARCHAR(50) NOT NULL,
	city VARCHAR(50) NOT NULL,
	country VARCHAR(50) NOT NULL,
	postal_code VARCHAR(50) NOT NULL,
	create_date date NOT NULL,
	start_date date,
	end_date date
);

CREATE TABLE  dim_store
(
	store_key integer NOT NULL PRIMARY KEY,
	address VARCHAR(100) NOT NULL,
	address2 VARCHAR(100),
	district VARCHAR(30) NOT NULL,
	city VARCHAR(30) NOT NULL,
	country VARCHAR(30) NOT NULL,
	postal_code VARCHAR(30) NOT NULL,
	manager_first_name VARCHAR(30) NOT NULL,
	manager_last_name VARCHAR(30),
	start_date date,
	last_date date
);

CREATE TABLE fact_sales
(
	sales_key SERIAL PRIMARY KEY,
	date_key integer REFERENCES dim_date(date_key),
	customer_key integer REFERENCES dim_customer(customer_key),
	movie_key integer REFERENCES dim_movie(movie_key),
	store_key integer REFERENCES dim_store(store_key),
	sales_amount integer NOT NULL
);

"Insert data in the table"
INSERT INTO dim_date
(date_key, date, year, quarter, month, week, day, is_weekend)
SELECT
	DISTINCT(TO_CHAR(payment_date :: DATE, 'YYYYMMDD')::integer) as date_key,
	date(payment_date) as date,
	EXTRACT(year FROM payment_date) as year,
	EXTRACT(quarter FROM payment_date) as quarter,
	EXTRACT(month FROM payment_date) as month,
	EXTRACT(week FROM payment_date) as week,
	EXTRACT(day FROM payment_date) as day,
	CASE WHEN EXTRACT(ISODOW FROM payment_date) IN (6,7) THEN true ELSE false END as is_weekend
FROM payment;

INSERT INTO dim_movie
(movie_key, title, description, release_year, language, original_language, length, rating, special_features)
SELECT
	f.film_id as movie_key,
	f.title,
	f.description,
	f.release_year,
	f.language_id as language,
	l.name as original_language,
	f.length,
	f.rating,
	f.special_features
FROM film f
JOIN language l ON f.language_id = l.language_id;
	
INSERT INTO dim_customer
(customer_key, first_name, last_name, email, address, address2, district, city, country, postal_code, create_date, start_date, end_date)
SELECT
	c.customer_id as customer_key,
	c.first_name,
	c.last_name,
	c.email,
	a.address,
	a.address2,
	a.district,
	ct.city,
	co.country,
	a.postal_code,
	c.create_date,
	now()    as start_date,
	now()    as end_date
FROM customer c
JOIN address a ON a.address_id = c.address_id
JOIN city ct ON ct.city_id = a.city_id
JOIN country co ON co.country_id = ct.country_id

SELECT column_name, data_type FROM information_schema.columns
WHERE table_name = 'film'

SELECT * FROM dim_movie;

INSERT INTO dim_store
(store_key, address, address2, district, city, country, postal_code, manager_first_name, manager_last_name, start_date, last_date)
SELECT 
	s.store_id as store_key,
	a.address,
	a.address2,
	a.district,
	ct.city,
	co.country,
	a.postal_code,
	sf.first_name as manager_first_name,
	sf.last_name as manager_last_name,
	now() as start_date,
	s.last_update as last_date
FROM store s
JOIN address a ON s.address_id = a.address_id
JOIN city ct ON ct.city_id = a.city_id
JOIN country co ON co.country_id = ct.country_id
JOIN staff sf ON sf.store_id = s.store_id

INSERT INTO fact_sales
(sales_key, date_key, customer_key, movie_key, store_key, sales_amount)
SELECT
	p.payment_id as sales_key,
	TO_CHAR(payment_date :: DATE, 'YYYYMMDD')::integer AS date_key,
	c.customer_id as customer_key,
	f.film_id as movie_key,
	s.store_id as store_key,
	p.amount as sales_amount
FROM payment p
JOIN customer c ON p.customer_id = c.customer_id
JOIN rental r ON p.rental_id = r.rental_id
JOIN inventory i ON r.inventory_id = i.inventory_id
JOIN film f ON i.film_id = f.film_id
JOIN store s ON i.store_id = s.store_id



SELECT dim_customer.first_name, dim_customer.last_name, dim_movie.title, dim_date.month, dim_store.city, SUM(fact_sales.sales_amount) as revenue
FROM fact_sales
JOIN dim_movie ON fact_sales.movie_key = dim_movie.movie_key
JOIN dim_date ON fact_sales.date_key = dim_date.date_key
JOIN dim_store ON fact_sales.store_key = dim_store.store_key
JOIN dim_customer ON fact_sales.customer_key = dim_customer.customer_key
GROUP BY dim_customer.first_name, dim_customer.last_name, dim_movie.title, dim_date.month, dim_store.city
ORDER BY SUM(fact_sales.sales_amount) DESC