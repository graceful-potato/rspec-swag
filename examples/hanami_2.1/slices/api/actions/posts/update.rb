# frozen_string_literal: true

module API::Actions::Posts
  class Update < API::Action
    include API::Deps[
      repo: "repositories.posts",
      post_serializer: "serializers.post"
    ]

    params do
      required(:id).value(:integer)
      required(:post).hash do
        optional(:title).value(:string)
        optional(:body).value(:string)
      end
    end

    def handle(request, response)
      halt 422, { error: request.params.errors }.to_json unless request.params.valid?
      post = repo.find(request.params[:id])
      halt 404, { error: "Not found" }.to_json unless post
      halt 422, { error: "Title or body should be in request." }.to_json if request.params[:post].empty?

      post = repo.update(post.id, request.params[:post])

      response.format = :json
      response.status = 200
      response.body = post_serializer.render(post)
    end
  end
end
