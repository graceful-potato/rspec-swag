# auto_register: false
# frozen_string_literal: true

module API
  class Repository < Blog::Repository
    struct_namespace API::Entities
  end
end
