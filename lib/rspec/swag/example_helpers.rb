# frozen_string_literal: true

require "rspec/swag/request_factory"
require "rspec/swag/response_validator"

module RSpec
  module Swag
    module ExampleHelpers
      def submit_request(metadata)
        request = RequestFactory.new.build_request(metadata, self)

        send(
          request[:verb],
          request[:path],
          request[:payload],
          request[:headers]
        )
      end

      def assert_response_matches_metadata(metadata)
        ResponseValidator.new.validate!(metadata, last_response)
      end
    end
  end
end
