# frozen_string_literal: true

require "rspec/core"
require "rspec/swag/example_group_helpers"
require "rspec/swag/example_helpers"
require "rspec/swag/configuration"

module RSpec
  module Swag
    # Extend RSpec with a swagger-based DSL
    ::RSpec.configure do |c|
      c.add_setting :openapi_root
      c.add_setting :openapi_specs
      c.add_setting :swagger_dry_run
      c.add_setting :openapi_format, default: :json
      c.add_setting :openapi_strict_schema_validation
      c.extend ExampleGroupHelpers, type: :request
      c.include ExampleHelpers, type: :request
    end

    def self.config
      @config ||= Configuration.new(RSpec.configuration)
    end

    def self.deprecator
      @deprecator ||= ActiveSupport::Deprecation.new("3.0", "rspec-swag")
    end
  end
end
