# frozen_string_literal: true

ROM::SQL.migration do
  change do
    create_table :posts do
      primary_key :id
      column :title, :text, null: false
      column :body, :text, null: false
      column :created_at, :datetime, null: false
      column :updated_at, :datetime, null: false

      index :id, unique: true
    end
  end
end
