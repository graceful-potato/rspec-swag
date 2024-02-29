# frozen_string_literal: true

module Blog
  class Routes < Hanami::Routes
    # Add your routes here. See https://guides.hanamirb.org/routing/overview/ for details.

    slice :api, at: "/api" do
      scope "v1" do
        get "/posts", to: "posts.index"
        get "/posts/:id", to: "posts.show"
        # post "/posts", to: "posts.create"
        # patch "/posts/:id", to: "posts.update"
        # delete "/posts/:id", to: "posts.destroy"
      end
    end
  end
end
