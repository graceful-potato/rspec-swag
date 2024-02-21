# frozen_string_literal: true

require "fileutils"

module RSpec
  module Swag
    class ProjectInitializer
      attr_reader :destination, :source

      def initialize
        @destination = Dir.pwd
        @source = File.expand_path("templates", __dir__)
      end

      def run
        copy_template "spec/swagger_helper.rb"
      end

      private

      def copy_template(file)
        destination_file = File.join(destination, file)
        return report_exists(file) if File.exist?(destination_file)

        report_creating(file)
        FileUtils.mkdir_p(File.dirname(destination_file))
        File.open(destination_file, "w") do |f|
          f.write File.read(File.join(source, file))
        end
      end

      def report_exists(file)
        puts "   exist   #{file}"
      end

      def report_creating(file)
        puts "  create   #{file}"
      end
    end
  end
end
