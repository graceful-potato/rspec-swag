# frozen_string_literal: true

require "blueprinter"

module Serializers
  class PostBlueprint < Blueprinter::Base
    identifier :id

    fields :title, :body, :created_at, :updated_at
  end
end
