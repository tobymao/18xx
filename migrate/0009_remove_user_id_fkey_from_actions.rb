# frozen_string_literal: true

Sequel.migration do
  up do
    alter_table :actions do
      drop_foreign_key [:user_id]
    end
  end
end
