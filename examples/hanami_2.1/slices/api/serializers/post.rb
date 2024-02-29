# frozen_string_literal: true

require "blueprinter"

module API::Serializers
  class Post < Blueprinter::Base
    include AutoInject

    identifier :id

    fields :title, :body, :created_at, :updated_at
  end
end
