# auto_register: false
# frozen_string_literal: true

module API::Serializers
  # HACK: register a serializer class in the container instead of a serializer instance
  module AutoInject
    def self.included(mod)
      mod.extend ClassMethods
    end

    module ClassMethods
      def new
        self
      end
    end
  end
end
