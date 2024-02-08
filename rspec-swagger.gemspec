# frozen_string_literal: true

$LOAD_PATH.push File.expand_path("lib", __dir__)

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "rspec-swagger"
  s.version     = "0.0.1"
  s.authors     = ["Richie Morris", "Greg Myers", "Jay Danielian", "GracefulPotato"]
  s.email       = ["gracefulpotatow@gmail.com"]
  s.homepage    = "https://github.com/"
  s.summary     = "An OpenAPI-based (formerly called Swagger) DSL for rspec & accompanying rake task for generating OpenAPI specification files"
  s.description = "Simplify API integration testing with a succinct rspec DSL and generate OpenAPI specification files directly from your rspec tests. More about the OpenAPI initiative here: http://spec.openapis.org/"
  s.license     = "MIT"

  s.files = Dir["{lib}/**/*"] + ["MIT-LICENSE", "Rakefile", ".rubocop_rspec_alias_config.yml"]

  s.add_dependency "activesupport", ">= 3.1", "< 7.2"
  s.add_dependency "json-schema", ">= 2.2", "< 5.0"
  s.add_dependency "rspec-core", ">=2.14", "< 4.0"

  s.add_development_dependency "rspec", "=3.13.0"
  s.add_development_dependency "rubocop", "=1.60.2"
  s.add_development_dependency "simplecov", "=0.21.2"
end
