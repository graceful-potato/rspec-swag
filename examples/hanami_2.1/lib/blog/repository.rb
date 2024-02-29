# frozen_string_literal: true

require "rom-repository"

module Blog
  class Repository < ROM::Repository::Root
    include Deps[container: "persistence.rom"]

    commands :create,
             use: :timestamps,
             plugins_options: {
               timestamps: {
                 timestamps: [:created_at, :updated_at]
               }
             }
    commands update: :by_pk,
             use: :timestamps,
             plugins_options: {
               timestamps: {
                 timestamps: :updated_at
               }
             }
    commands delete: :by_pk

    def find(id)
      root.by_pk(id).one
    end

    def all
      root.to_a
    end
  end
end
