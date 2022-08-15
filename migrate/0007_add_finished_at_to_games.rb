# frozen_string_literal: true

Sequel.migration do
  change do
    add_column :games, :finished_at, DateTime
  end
end
