require 'generator_spec'
require 'generators/rswag/specs/install/install_generator'

module Rswag
  module Specs

    describe InstallGenerator do
      include GeneratorSpec::TestCase
      destination File.expand_path('../tmp', __FILE__)

      before(:all) do
        prepare_destination
        fixtures_dir = File.expand_path('../fixtures', __FILE__)
        FileUtils.cp_r("#{fixtures_dir}/spec", destination_root)

        run_generator
      end

      it 'installs the swagger_helper for rspec' do
        assert_file('spec/swagger_helper.rb')
      end
    end
  end
end
