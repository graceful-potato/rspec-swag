# frozen_string_literal: true

require "rspec/swag"
require "rspec/core/rake_task"
require "rspec/swag/project_initializer"

namespace :rspec do
  desc "Generate Swagger JSON files from integration specs"
  RSpec::Core::RakeTask.new("swaggerize") do |t|
    t.pattern = ENV.fetch(
      "PATTERN",
      "spec/requests/**/*_spec.rb, spec/api/**/*_spec.rb, spec/integration/**/*_spec.rb"
    )

    additional_rspec_opts = ENV.fetch(
      "ADDITIONAL_RSPEC_OPTS",
      ""
    )

    t.rspec_opts = [additional_rspec_opts]

    t.rspec_opts += if RSpec::Swag.config.swagger_dry_run
                      ["--format RSpec::Swag::SwaggerFormatter", "--dry-run", "--order defined"]
                    else
                      ["--format RSpec::Swag::SwaggerFormatter", "--order defined"]
                    end
  end

  namespace :swag do
    desc "Copy swagger_helper.rb to spec/"
    task :install do
      RSpec::Swag::ProjectInitializer.new.run
    end
  end
end

task swaggerize: ["rspec:swaggerize"]
