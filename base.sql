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
(default, 'Игорь','холост'),
(default, 'Саша','женат');
INSERT INTO account VALUES 
(default, 'igor','pass','igor@gmail.com',1), 
(default, 'sasha','pass','sasha@gmail.com',2);
INSERT INTO post VALUES 
(default, 'Автомобиль', 'Красная машина', '09-18-2017', default, 1)
INSERT INTO post VALUES 
(default, 'Машина', 'Синяя машина', default, default, 2)
INSERT INTO post VALUES 
(default, 'Велик', 'Зеленый велик', default, default, 2)

COMMIT;


--SELECT person_id, max(created_at) FROM POST GROUP BY person_id 
