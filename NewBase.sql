--RESET ROLE;
--DROP SCHEMA forum1 CASCADE;
BEGIN;

CREATE SCHEMA forum1;
SET search_path TO forum1;

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
CREATE TABLE tag (
	id SERIAL PRIMARY KEY, 
	name text
);

CREATE TABLE tag_post (
	post_id int REFERENCES post(id), 
	tag_id int REFERENCES tag(id), 
	PRIMARY KEY(post_id, tag_id)
);

CREATE FUNCTION set_date() RETURNS TRIGGER AS 
	$$
	begin
		new.edited_at:=now();
		return new;
	end;
	$$ 
LANGUAGE plpgsql;

CREATE TRIGGER on_post_update BEFORE UPDATE ON post 
FOR EACH ROW EXECUTE PROCEDURE set_date();

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

CREATE TYPE role AS ENUM ('user_mangir','moderator_mangir','admin_mangir');

CREATE TYPE jwt AS (role role, person_id int);

CREATE OR REPLACE FUNCTION change_password(password varchar(20), person_id int) RETURNS void AS 
$$
begin
  UPDATE account SET hash = crypt(password, gen_salt('md5')) WHERE account.id = change_password.person_id;
end;
$$ 
LANGUAGE plpgsql SECURITY DEFINER;

CREATE OR REPLACE FUNCTION authentication(login varchar(20), password varchar(20)) RETURNS jwt AS 
$$
declare ac account;
begin
  SELECT * INTO ac FROM account WHERE account.login = authentication.login;
  if ac.hash = crypt(password, ac.hash) THEN  
    RETURN (ac.role, ac.person_id)::jwt;
  ELSE RETURN NULL;
  end if;
end;
$$ 
LANGUAGE plpgsql SECURITY DEFINER;



GRANT admin_mangir, moderator_mangir, user_mangir, anonim_mangir TO mangir;

GRANT USAGE ON schema forum TO admin_mangir, moderator_mangir, user_mangir, anonim_mangir;
GRANT ALL ON post TO admin_mangir, moderator_mangir, user_mangir;
GRANT ALL ON account TO admin_mangir;
GRANT ALL ON likes TO admin_mangir, moderator_mangir;
GRANT ALL ON person TO admin_mangir, moderator_mangir;
GRANT ALL ON tag TO admin_mangir, moderator_mangir;
GRANT ALL ON tag_post TO admin_mangir, moderator_mangir;

GRANT SELECT, UPDATE, DELETE ON post, likes, person TO user_mangir;
GRANT SELECT ON account, person TO user_mangir;
GRANT ALL ON post,account,likes,person,tag,tag_post TO moderator_mangir;
GRANT ALL ON post,account,likes,person,tag,tag_post TO admin_mangir;
GRANT SELECT ON account TO moderator_mangir;
GRANT SELECT, UPDATE ON account TO admin_mangir;
ALTER TABLE post ENABLE ROW LEVEL SECURITY;
ALTER TABLE likes ENABLE ROW LEVEL SECURITY;
ALTER TABLE person ENABLE ROW LEVEL SECURITY;
ALTER TABLE likes ENABLE ROW LEVEL SECURITY;
ALTER TABLE person ENABLE ROW LEVEL SECURITY;
ALTER TABLE tag ENABLE ROW LEVEL SECURITY;
CREATE POLICY read_post ON post FOR SELECT TO admin_mangir, moderator_mangir, user_mangir, anonim_mangir
USING (true);

CREATE POLICY read_post1 ON post FOR UPDATE TO user_mangir
USING (current_setting('jwt.user_id')::int=person_id);

CREATE POLICY read_tag ON post FOR SELECT TO admin_mangir, moderator_mangir, user_mangir, anonim_mangir
USING (true);

CREATE POLICY delete_post ON post FOR DELETE TO user_mangir
USING (current_setting('jwt.user_id')::int=person_id);

commit;


---------------------------------------------------------------------------------------------------------

--CREATE INDEX post_index ON post USING GIN (to_tsvector('english', title ||' '|| body));

SELECT ts_headline('english', body,  'porro <3> fugiat'), ts_rank(to_tsvector('english', title ||' '|| body), to_tsquery('english', 'porro <3> fugiat')) FROM post 
WHERE to_tsvector('english', title ||' '|| body) @@ to_tsquery('english', 'porro <3> fugiat') ORDER BY ts_rank DESC;

--EXPLAIN ANALYSE 



CREATE VIEW posts_with_short_title AS 
SELECT 
	title,
	count(part)
FROM (
	SELECT 
		id, 
		regexp_split_to_table(title, E'\\s+') AS part,
		title
	FROM post) AS split_title 
GROUP BY title HAVING count(part) <= 3;


CREATE OR REPLACE FUNCTION random_number(a int, b int) RETURNS int AS
$$
BEGIN
	RETURN floor(a+random()*(b-a+1));
END;
$$ 
LANGUAGE plpgsql SECURITY DEFINER;

UPDATE post SET post_holder_id = random_number(601, 1300) WHERE id BETWEEN 1301 AND 2000

--------------------------------------
WITH RECURSIVE included_comments(post_holder_id, id) AS (
		  SELECT post_holder_id, id FROM post WHERE post_holder_id BETWEEN 1 AND 200
		UNION ALL
		    SELECT
			post.post_holder_id,
			post.id
		    FROM included_comments, post 
		    WHERE included_comments.id=post.post_holder_id
		  )
SELECT count(id) FROM included_comments
