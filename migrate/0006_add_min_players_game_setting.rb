# frozen_string_literal: true

Sequel.migration do
  change do
    add_column :games, :min_players, Integer, null: false, default: 3
  end
end
