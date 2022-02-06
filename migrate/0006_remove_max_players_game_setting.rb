# frozen_string_literal: true

Sequel.migration do
  change do
    alter_table :games do
      drop_column :max_players
    end
  end
end
