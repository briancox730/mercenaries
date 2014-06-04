CREATE TABLE users (
  id serial PRIMARY KEY,
  username varchar(255) NOT NULL,
  salt varchar(255) NOT NULL,
  digest varchar(255) NOT NULL,
  role varchar(255) NOT NULL,
);

CREATE TABLE calendar (

);
