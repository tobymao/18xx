# frozen_string_literal: true

Sequel.migration do
  change do
    add_column :games, :elo, :jsonb, null: false, default: '{}'
    add_column :games, :finished_at, DateTime
    add_column :users, :stats, :jsonb, null: false, default: '{}'
  end
end
