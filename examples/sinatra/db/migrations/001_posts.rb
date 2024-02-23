# frozen_string_literal: true

Sequel.migration do
  up do
    create_table(:posts) do
      primary_key :id

      String :title, null: false
      String :body, null: false
      DateTime :created_at
      DateTime :updated_at

      index :id, unique: true
    end
  end

  down do
    drop_table(:posts)
  end
end
