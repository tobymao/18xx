# frozen_string_literal: true

Sequel.migration do
  change do
    add_column :games, :manually_ended, :boolean
  end
end
