# frozen_string_literal: true

Sequel.migration do
  change do
    add_column :users, :settings, :jsonb, null: false, default: '{}'
  end
end
