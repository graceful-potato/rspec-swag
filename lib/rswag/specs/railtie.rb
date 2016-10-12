module Rswag
  module Specs
    class Railtie < ::Rails::Railtie

      rake_tasks do
        load File.expand_path('../../../tasks/rswag-specs_tasks.rake', __FILE__)
      end
    end
  end
end
