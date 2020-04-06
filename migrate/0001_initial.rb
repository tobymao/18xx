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

      index Sequel.lit('lower(name)'), type: :btree
      index Sequel.lit('lower(email)'), type: :btree
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
      column :users, 'integer[]', null: false
      String :description, null: false
      String :title, null: false
      jsonb :state, null: false, default: '{}'

      DateTime :created_at, null: false
      DateTime :updated_at, null: false

      index :users, type: 'gin'
      index :state, type: 'gin'
    end

    create_table :actions do
      foreign_key :game_id, :games, null: false, index: true, on_delete: :cascade
      Integer :id, null: false
      primary_key %w[game_id id]

      String :round, null: false
      Integer :turn, null: false
      json :action, null: false

      DateTime :created_at, null: false
      DateTime :updated_at, null: false
    end
  end
end
