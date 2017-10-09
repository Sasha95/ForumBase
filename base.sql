--CREATE SCHEMA forum;
--ALTER DATABASE mangir SET search_path TO forum, public;

SET search_path TO forum, public;

BEGIN;

CREATE TABLE person (
    id SERIAL PRIMARY KEY, 
    name VARCHAR(100),
    status TEXT
);
CREATE TABLE account (
    id SERIAL PRIMARY KEY,
    login VARCHAR(20) NOT NULL UNIQUE,
    password VARCHAR(20) NOT NULL,
    email TEXT NOT NULL UNIQUE,
    person_id INTEGER REFERENCES person(id)
);
CREATE TABLE post(
    id SERIAL PRIMARY KEY, 
    title VARCHAR(200),
    post TEXT,
    created_at TIMESTAMP DEFAULT now(),
    post_id INTEGER REFERENCES post(id),
    person_id INTEGER REFERENCES person(id)
);
CREATE TABLE likes(
    person_id INTEGER REFERENCES person(id),
    post_id INTEGER REFERENCES post(id),
    person_like BOOLEAN,
    PRIMARY KEY (person_id, post_id)
);

INSERT INTO person VALUES 
(default, 'Èãîðü','õîëîñò'),
(default, 'Ñàøà','æåíàò');
INSERT INTO account VALUES 
(default, 'igor','pass','igor@gmail.com',1), 
(default, 'sasha','pass','sasha@gmail.com',2);
INSERT INTO post VALUES 
(default, 'Àâòîìîáèëü', 'Êðàñíàÿ ìàøèíà', '09-18-2017', default, 1)
INSERT INTO post VALUES 
(default, 'Ìàøèíà', 'Ñèíÿÿ ìàøèíà', default, default, 2)
INSERT INTO post VALUES 
(default, 'Âåëèê', 'Çåëåíûé âåëèê', default, default, 2)

COMMIT;

--SELECT person_id, max(created_at) FROM post GROUP BY person_id
--SELECT DISTINCT person_id, max(created_at) OVER (PARTITION BY person_id ) FROM post 

CREATE OR REPLACE FUNCTION my_func(name1 text, beg integer, end1 int) RETURNS text
AS $$SELECT SUBSTRING(name1,beg,end1)$$ LANGUAGE SQL;

SELECT title, my_func(title, 1, 2) FROM post;

CREATE OR REPLACE FUNCTION my_func(person_id int) RETURNS timestamp
AS $$SELECT max(created_at) FROM post as p2 WHERE my_func.person_id = p2.person_id$$ LANGUAGE SQL;

SELECT person_id, title, created_at FROM post WHERE created_at = my_func(person_id)


CREATE FUNCTION myfunc() RETURNS TRIGGER AS 
$$
begin
new.edited_at:=now();
return new;
end;
$$ 
LANGUAGE plpgsql

CREATE TRIGGER on_post_update BEFORE UPDATE ON post 
FOR EACH ROW EXECUTE PROCEDURE myfunc()


CREATE OR REPLACE FUNCTION registration(login varchar(20), password varchar(20), email text, name varchar(100)) RETURNS void AS 
$$
declare 
per_id int;
begin
  INSERT INTO person (name) VALUES (name)
    RETURNING id INTO per_id;
  INSERT INTO account (login, password, email, person_id) VALUES (login, password, email, per_id);
end;
$$ 
LANGUAGE plpgsql SECURITY DEFINER; 

CREATE OR REPLACE FUNCTION registration(login varchar(20), password varchar(20), email text, name varchar(100), status text) RETURNS void AS 
$$
declare 
per_id int;
begin
  INSERT INTO person (name, status) VALUES (name, status)
    RETURNING id INTO per_id;
  INSERT INTO account (login, password, email, person_id) VALUES (login, password, email, per_id);
end;
$$ 
LANGUAGE plpgsql SECURITY DEFINER;
--хэш
CREATE OR REPLACE FUNCTION registration(login varchar(20), password varchar(20), email text, name varchar(100), status text) RETURNS void AS 
$$
declare 
per_id int;
begin
  INSERT INTO person (name, status) VALUES (name, status)
    RETURNING id INTO per_id;
  INSERT INTO account (login, hash, email, person_id) VALUES (login, crypt(password, gen_salt('md5')), email, per_id);
end;
$$ 
LANGUAGE plpgsql SECURITY DEFINER;

SELECT * FROM registration('Vasyewfewa3', '123', 'rfew2@mail.ru', 'Ва11', 'неженат');

CREATE ROLE anonim_mangir;
CREATE ROLE user_mangir;
CREATE ROLE moderator_mangir;
CREATE ROLE admin_mangir;

CREATE TYPE rols AS ENUM ('anonim_mangir','user_mangir','moderator_mangir','admin_mangir');

CREATE TYPE jwt AS (role roles, person_id int)

