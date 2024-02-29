# frozen_string_literal: true

module API::Actions::Posts
  class Index < API::Action
    include API::Deps[
      repo: "repositories.posts",
      post_serializer: "serializers.post"
    ]

    def handle(_request, response)
      posts = repo.all
      response.format = :json
      response.body = post_serializer.render(posts)
    end
  end
end
