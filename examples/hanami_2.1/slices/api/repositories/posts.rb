# frozen_string_literal: true

module API::Repositories
  class Posts < API::Repository[:posts]
    struct_namespace API::Entities
  end
end
