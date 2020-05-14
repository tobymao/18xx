# frozen_string_literal: true

Sequel.migration do
  change do
    add_column :games, :pin_version, String, null: true, default: nil
  end
end
