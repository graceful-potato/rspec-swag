# frozen_string_literal: true

module API::Actions::Posts
  class Destroy < API::Action
    include API::Deps[
      repo: "repositories.posts",
      post_serializer: "serializers.post"
    ]

    params do
      required(:id).value(:integer)
    end

    def handle(request, response)
      halt 422, { error: request.params.errors }.to_json unless request.params.valid?
      post = repo.find(request.params[:id])
      halt 404, { error: "Not found" }.to_json unless post

      repo.delete(post.id)

      response.format = :json
      response.body = post_serializer.render(post)
    end
  end
end
