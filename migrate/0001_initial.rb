# frozen_string_literal: true

Sequel.migration do
  change do
    create_table :users do
      primary_key :id, type: :Bignum

      String :name, null: false
      String :password, null: false
      String :email, null: false

      DateTime :created_at, null: false
      DateTime :updated_at, null: false

      index Sequel.lit('lower(name)'), type: :btree, unique: true
      index Sequel.lit('lower(email)'), type: :btree, unique: true
    end

    create_table :sessions do
      primary_key :id, type: :Bignum

      String :token, null: false, index: true, unique: true
      foreign_key :user_id, :users, null: false, index: true, on_delete: :cascade

      DateTime :created_at, null: false
      DateTime :updated_at, null: false
    end

    create_table :games do
      primary_key :id, type: :Bignum

      foreign_key :user_id, :users, null: false, index: true, on_delete: :cascade
      String :description, null: false

      String :title, null: false
      Integer :max_players, null: false, default: 6
      jsonb :settings, null: false, default: '{}'
      String :status, null: false, default: 'new'
      Integer :turn, null: false, default: 1
      String :round, null: false

      column :acting, 'integer[]'
      jsonb :result

      DateTime :created_at, null: false
      DateTime :updated_at, null: false

      index :acting, type: :gin
      index :result, type: :gin
    end

    create_table :game_users do
      primary_key :id, type: :Bignum
      foreign_key :game_id, :games, null: false, on_delete: :cascade
      foreign_key :user_id, :users, null: false, index: true, on_delete: :cascade

      DateTime :created_at, null: false
      DateTime :updated_at, null: false

      index %i[game_id user_id], unique: true
    end

    create_table :actions do
      primary_key :id, type: :Bignum
      foreign_key :game_id, :games, null: false, on_delete: :cascade
      foreign_key :user_id, :users, null: false, on_delete: :cascade
      Integer :action_id, null: false

      Integer :turn, null: false
      String :round, null: false
      jsonb :action, null: false

      DateTime :created_at, null: false
      DateTime :updated_at, null: false

      index %i[game_id action_id], unique: true
    end
  end
end
