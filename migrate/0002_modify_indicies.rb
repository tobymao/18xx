# frozen_string_literal: true

Sequel.migration do
  up do
    drop_index :games, :result
    drop_index :games, :acting
    add_index :games, %i[status created_at]

    drop_index :sessions, :user_id
    add_index :sessions, %i[user_id updated_at]
    add_index :sessions, :created_at
  end

  down do
    drop_index :sessions, :created_at
    drop_index :sessions, %i[user_id updated_at]
    add_index :sessions, :user_id

    drop_index :games, %i[status created_at]
    add_index :games, :acting, type: :gin
    add_index :games, :result, type: :gin
  end
end
