CREATE TABLE business (
  id serial PRIMARY KEY,
  name varchar(255) NOT NULL,
  owner varchar(255) NOT NULL,
  description varchar(1023) NOT NULL
);

CREATE TABLE employees (
  id serial PRIMARY KEY,
  business_id integer REFERENCES business(id) NOT NULL,
  first_name varchar(255) NOT NULL,
  last_name varchar(255) NOT NULL,
  role varchar(1023) NOT NULL,
);

CREATE TABLE calendar (
);
