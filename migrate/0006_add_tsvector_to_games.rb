# frozen_string_literal: true

Sequel.migration do
  up do
    run("
SET SCHEMA 'public';
ALTER TABLE games ADD COLUMN tsv tsvector;

CREATE INDEX games_tsv_index ON games USING gin (tsv);

UPDATE games g
SET tsv =
  setweight(to_tsvector(g.title), 'A') ||
  setweight(to_tsvector(SUBSTRING(g.title, 3, 99)), 'A') ||
  setweight(to_tsvector(g.round), 'D') ||
  setweight(to_tsvector(CAST(g.turn AS text)), 'D') ||
  setweight(to_tsvector(COALESCE(g.settings->>'optional_rules', '')), 'D') ||
  setweight(to_tsvector(COALESCE(g.description, '')), 'C') ||
  setweight(to_tsvector(
    (SELECT STRING_AGG(u.name, ' ')
      FROM users u
      INNER JOIN game_users gu ON u.id = gu.user_id
      WHERE gu.game_id = g.id)
  ), 'B');

CREATE OR REPLACE FUNCTION update_game_tsv() RETURNS trigger AS $$
BEGIN
  IF OLD.round <> NEW.round THEN
    UPDATE games g
    SET tsv = (setweight(to_tsvector(g.title), 'A') ||
      setweight(to_tsvector(SUBSTRING(g.title, 3, 99)), 'A') ||
      setweight(to_tsvector(g.round), 'D') ||
      setweight(to_tsvector(CAST(g.turn AS text)), 'D') ||
      setweight(to_tsvector(COALESCE(g.settings->>'optional_rules', '')), 'D') ||
      setweight(to_tsvector(COALESCE(g.description, '')), 'C') ||
      setweight(to_tsvector(
        (SELECT STRING_AGG(u.name, ' ')
          FROM users u
          INNER JOIN game_users gu ON u.id = gu.user_id
          WHERE gu.game_id = NEW.id)
      ), 'B'))
    WHERE g.id = NEW.id;
  END IF;
  RETURN NULL;
END
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS update_game ON games;
CREATE TRIGGER update_game
AFTER UPDATE OF round ON games
FOR EACH ROW EXECUTE FUNCTION update_game_tsv();
/* first update after start => no update on users joining */

CREATE OR REPLACE FUNCTION insert_game_tsv() RETURNS trigger AS $$
BEGIN
  UPDATE games g
  SET tsv = (setweight(to_tsvector(g.title), 'A') ||
    setweight(to_tsvector(SUBSTRING(g.title, 3, 99)), 'A') ||
    setweight(to_tsvector(g.round), 'D') ||
    setweight(to_tsvector(CAST(g.turn AS text)), 'D') ||
    setweight(to_tsvector(COALESCE(g.settings->>'optional_rules', '')), 'D') ||
    setweight(to_tsvector(COALESCE(g.description, '')), 'C') ||
    setweight(to_tsvector(
      (SELECT u.name
        FROM users u
        WHERE u.id = g.user_id)
    ), 'B'))
  WHERE g.id = NEW.id;
  RETURN NULL;
END
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS insert_game ON games;
CREATE TRIGGER insert_game
AFTER INSERT ON games
FOR EACH ROW EXECUTE FUNCTION insert_game_tsv();

CREATE OR REPLACE FUNCTION update_user_tsv() RETURNS trigger AS $$
BEGIN
  IF OLD.name <> NEW.name THEN
    UPDATE games g
    SET tsv = (setweight(to_tsvector(title), 'A') ||
      setweight(to_tsvector(SUBSTRING(g.title, 3, 99)), 'A') ||
      setweight(to_tsvector(round), 'D') ||
      setweight(to_tsvector(CAST(turn AS text)), 'D') ||
      setweight(to_tsvector(COALESCE(settings->>'optional_rules', '')), 'D') ||
      setweight(to_tsvector(COALESCE(description, '')), 'C') ||
      setweight(to_tsvector(
        (SELECT STRING_AGG(name, ' ')
          FROM users u
          INNER JOIN game_users gu ON u.id = gu.user_id
          WHERE gu.game_id = g.id)
      ), 'B'))
    WHERE id IN (
      SELECT game_id
      FROM game_users gu2
      WHERE gu2.user_id = OLD.id
    );
  END IF;
  RETURN NULL;
END
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS update_username ON users;
CREATE TRIGGER update_username
AFTER UPDATE OF name ON users
FOR EACH ROW EXECUTE FUNCTION update_user_tsv();
    ")
  end

  down do
    run("
SET SCHEMA 'public';
ALTER TABLE games DROP COLUMN tsv;
DROP FUNCTION update_game_tsv() CASCADE;
DROP FUNCTION insert_game_tsv() CASCADE;
DROP FUNCTION update_user_tsv() CASCADE;
    ")
  end
end
