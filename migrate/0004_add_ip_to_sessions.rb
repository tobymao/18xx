# frozen_string_literal: true

Sequel.migration do
  change do
    add_column :sessions, :ip, String, null: false, default: ''
    add_index :sessions, :ip
  end
end
