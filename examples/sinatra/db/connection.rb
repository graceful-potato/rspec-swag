# frozen_string_literal: true

require "sequel"

env = ENV["RACK_ENV"] || "development"

DB = Sequel.connect("sqlite://db/blog_#{env}.sqlite3")
