BEGIN;
CREATE TABLE user (
    id SERIAL PRIMARY KEY, 
    name VARCHAR(100),
    status TEXT
);
CREATE TABLE account (
    id SERIAL PRIMARY KEY,
    login VARCHAR(20) NOT NULL UNIQUE,
    password VARCHAR(20) NOT NULL,
    email TEXT NOT NULL UNIQUE,
    user_id INTEGER REFERENCES user(id)

);
CREATE TABLE post(
    id SERIAL PRIMARY KEY, 
    title VARCHAR(200),
    post TEXT,
    created_at TIMESTAMP,
    post_id INTEGER REFERENCES post(id),
    user_id INTEGER REFERENCES user(id)
);
CREATE TABLE likes(
    user_id INTEGER REFERENCES user(id),
    post_id INTEGER REFERENCES post(id),
    user_like BOOLEAN,
    PRIMARY KEY (user_id, post_id)
);
COMMIT;

--SET search_path TO forum, public;


INSERT INTO forum.user VALUES 
(default, 'Игорь','холост'),
(default, 'Саша','женат');
INSERT INTO forum.account VALUES 
(default, 'igor','pass','igor@gmail.com',1), 
(default, 'sasha','pass','sasha@gmail.com',2);