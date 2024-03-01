# frozen_string_literal: true

require "hanami"

module Blog
  class App < Hanami::App
    config.middleware.use :body_parser, :json
    config.actions.content_security_policy[:script_src] += " https://unpkg.com/ 'unsafe-inline'"
  end
end
