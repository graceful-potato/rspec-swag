# frozen_string_literal: true

$LOAD_PATH.push File.expand_path("lib", __dir__)
require "rspec/swag/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "rspec-swag"
  s.version     = RSpec::Swag::VERSION
  s.authors     = ["Richie Morris", "Greg Myers", "Jay Danielian", "GracefulPotato"]
  s.email       = ["gracefulpotatow@gmail.com"]
  s.homepage    = "https://github.com/graceful-potato/rspec-swag"
  s.metadata    = {
    "source_code_uri" => "https://github.com/graceful-potato/rspec-swag",
    "homepage_uri"    => "https://github.com/graceful-potato/rspec-swag",
  }
  s.summary     = "An OpenAPI-based (formerly called Swagger) DSL for rspec & accompanying rake task for generating OpenAPI specification files"
  s.description = "Fork of rswag-specs. Compatible with any rack framework like Sinatra, Padrino, Hanami, Roda, etc. Simplify API integration testing with a succinct rspec DSL and generate OpenAPI specification files directly from your rspec tests. More about the OpenAPI initiative here: http://spec.openapis.org/"
  s.license     = "MIT"

  s.files = Dir["lib/**/*"] + ["MIT-LICENSE", "Rakefile", ".rubocop_rspec_alias_config.yml"]

  s.add_dependency "activesupport", ">= 3.1", "< 7.2"
  s.add_dependency "json-schema", ">= 2.2", "< 5.0"
  s.add_dependency "rspec-core", ">=3.0", "< 4.0"

  s.add_development_dependency "rspec", "=3.13.0"
  s.add_development_dependency "climate_control", ">=1.0.0", "< 2.0"
  s.add_development_dependency "rubocop", "=1.60.2"
  s.add_development_dependency "simplecov", "=0.21.2"
end
