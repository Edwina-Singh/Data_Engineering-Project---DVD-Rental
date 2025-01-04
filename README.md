# Data_Engineering-Project---DVD Rental using PostgreSQL and Data Model

# Overview
We downloaded the sample data and redesigned the schema into dimension tables using drawio. Then, we created a PostgreSQL database to enable efficient querying and analysis.

# Dataset used
The Neon Tech contain PostgreSQL Sample Database of DVD Rental(.tar format). The DVD rental database represents the business processes of a DVD rental store. The DVD rental database has many objects, including: 15 tables, 1 trigger, 7 views, 8 functions, 1 domain, 13 sequences.

It also provide ER Diagram which contain 15 tables in the DVD Rental database:
  . actor – stores actor data including first name and last name.
  . film – stores film data such as title, release year, length, rating, etc.
  . film_actor – stores the relationships between films and actors.
  . category – stores film’s categories data.
  . film_category- stores the relationships between films and categories.
  . store – contains the store data including manager staff and address.
  . inventory – stores inventory data.
  . rental – stores rental data.
  . payment – stores customer’s payments.
  . staff – stores staff data.
  . customer – stores customer data.
  . address – stores address data for staff and customers
  . city – stores city names.
  . country – stores country names.

https://neon.tech/postgresql/postgresql-getting-started/postgresql-sample-database

# DVD Rental E-R Diagram

[Postgresql database diagram.pdf](https://github.com/user-attachments/files/18304690/Postgresql.database.diagram.pdf)


