CREATE TABLE users (
  id serial PRIMARY KEY,
  business_id integer NOT NULL REFERENCES businesses(id),
  username varchar(255) NOT NULL,
  salt varchar(255) NOT NULL,
  digest varchar(255) NOT NULL,
  role varchar(255) NOT NULL
);

CREATE TABLE entries (
  id serial PRIMARY KEY,
  business_id integer NOT NULL REFERENCES businesses(id),
  start_time timestamp NOT NULL,
  end_time timestamp NOT NULL,
  role_id integer NOT NULL REFERENCES roles(id),
  assigned_id integer REFERENCES users(id)
);

CREATE TABLE user_roles (
  id serial PRIMARY KEY,
  user_id integer NOT NULL REFERENCES users(id),
  role_id integer NOT NULL REFERENCES roles(id)
);

CREATE TABLE roles (
  id serial PRIMARY KEY,
  name varchar(255)
);

CREATE TABLE businesses (
  id serial PRIMARY KEY
  name varchar(255) NOT NULL
  );
