# frozen_string_literal: true

module API::Actions::Posts
  class Create < API::Action
    include API::Deps[
      repo: "repositories.posts",
      post_serializer: "serializers.post"
    ]

    params do
      required(:post).hash do
        required(:title).filled(:string)
        required(:body).filled(:string)
      end
    end

    def handle(request, response)
      halt 422, { error: request.params.errors }.to_json unless request.params.valid?
      post = repo.create(request.params[:post])

      response.format = :json
      response.status = 201
      response.body = post_serializer.render(post)
    end
  end
end
