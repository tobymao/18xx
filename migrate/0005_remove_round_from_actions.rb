# frozen_string_literal: true

Sequel.migration do
  up do
    alter_table :actions do
      drop_column :turn
      drop_column :round
      drop_column :id
      drop_index %i[game_id action_id]

      set_column_type :game_id, :bigint
      set_column_type :user_id, :bigint

      add_primary_key %i[game_id action_id], name: :actions_pkey
    end

    alter_table :games do
      set_column_type :user_id, :bigint
    end

    alter_table :game_users do
      set_column_type :game_id, :bigint
      set_column_type :user_id, :bigint
    end

    alter_table :sessions do
      set_column_type :user_id, :bigint
    end
  end

  down do
    alter_table :actions do
      # this migration is not backwards compatible with data because round and turn are lost
      drop_constraint :actions_pkey
      add_index %i[game_id action_id], unique: true
      add_primary_key :id, type: :Bignum
      add_column :round, String, null: false, default: ''
      add_column :turn, Integer, null: false, default: 0
    end
  end
end
