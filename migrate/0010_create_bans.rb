# frozen_string_literal: true

Sequel.migration do
  change do
    create_table :bans do
      primary_key :id, type: :Bignum

      foreign_key :user_id, :users, index: { unique: true }, on_delete: :cascade
      String :ip, index: { unique: true }
      String :reason
      foreign_key :created_by, :users, on_delete: :set_null

      DateTime :created_at, null: false
      DateTime :updated_at, null: false
    end
  end
end
