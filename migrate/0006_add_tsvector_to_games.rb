# frozen_string_literal: true

Sequel.migration do
  up do
    alter_table :games do
      add_column :tsv, :tsvector # , null: false, default: ''
      add_index :tsv, type: :gin
    end

    run "
      UPDATE games g
      SET tsv = setweight(to_tsvector(g.title), 'A') ||
          setweight(to_tsvector(SUBSTRING(g.title, 3, 99)), 'A') ||
          setweight(to_tsvector(g.round), 'D') ||
          setweight(to_tsvector(CAST(g.turn AS text)), 'D') ||
          setweight(to_tsvector(COALESCE(g.settings->>'optional_rules', '')), 'D') ||
          setweight(to_tsvector(COALESCE(g.description, '')), 'C') ||
          setweight(to_tsvector(
            (SELECT STRING_AGG(u.name, ' ')
              FROM users u
              INNER JOIN game_users gu ON u.id = gu.user_id
              INNER JOIN games g2 ON g2.id = gu.game_id
              WHERE g.id = g2.id)
          ), 'B');
    "

    run "
      DROP FUNCTION IF EXISTS games_trigger() CASCADE;

      CREATE OR REPLACE FUNCTION games_trigger() RETURNS trigger AS $$
      BEGIN
        UPDATE games g
        SET tsv = (setweight(to_tsvector(g.title), 'A') ||
            setweight(to_tsvector(g.round), 'D') ||
            setweight(to_tsvector(CAST(g.turn AS text)), 'D') ||
            setweight(to_tsvector(COALESCE(g.settings->>'optional_rules', '')), 'D') ||
            setweight(to_tsvector(COALESCE(g.description, '')), 'C') ||
            setweight(to_tsvector(
              (SELECT STRING_AGG(u.name, ' ')
                FROM users u
                INNER JOIN game_users gu ON u.id = gu.user_id
                INNER JOIN games g2 ON g2.id = gu.game_id
                WHERE g.id = g2.id)
            ), 'B'));
        RETURN NEW;
      END
      $$ LANGUAGE plpgsql;

      CREATE TRIGGER tsv_update
      AFTER UPDATE OF round, turn ON games
      FOR EACH ROW EXECUTE FUNCTION games_trigger();

      CREATE TRIGGER tsv_insert
      AFTER INSERT ON games
      FOR EACH ROW EXECUTE FUNCTION games_trigger();
    "
  end

  down do
    alter_table :games do
      drop_column :tsv
      drop_index :tsv
    end
    run 'DROP FUNCTION IF EXISTS games_trigger() CASCADE;'
    run 'DROP TRIGGER IF EXISTS tsv_update ON games;'
    run 'DROP TRIGGER IF EXISTS tsv_insert ON games;'
  end
end
