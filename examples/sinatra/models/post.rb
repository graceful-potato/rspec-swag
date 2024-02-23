# frozen_string_literal: true

require_relative "../db/connection"

class Post < Sequel::Model
  def validate
    super
    errors.add(:title, "cannot be empty") if !title || title.empty?
    errors.add(:body, "cannot be empty") if !body || body.empty?
  end
end
