# frozen_string_literal: true

require "sinatra/base"
require "json"
require_relative "config/initializers"
require_relative "models/post"
require_relative "serializers/post_blueprint"

class Blog < Sinatra::Base
  get "/" do
    erb :index
  end

  get "/posts" do
    posts = Post.all

    Serializers::PostBlueprint.render(posts)
  end

  get "/posts/:id" do |id|
    post = Post[id]
    halt 404, { error: "Not found" }.to_json if post.nil?

    Serializers::PostBlueprint.render(post)
  end

  post "/posts" do
    data = JSON.parse(request.body.read).slice("title", "body")
    post = Post.new(data)
    halt 422, { error: post.errors }.to_json unless post.valid?
    post.save

    status 201
    Serializers::PostBlueprint.render(post)
  end

  patch "/posts/:id" do |id|
    data = JSON.parse(request.body.read).slice("title", "body")
    post = Post[id]
    halt 404, { error: "Not found" }.to_json if post.nil?
    post.update(data)

    Serializers::PostBlueprint.render(post)
  end

  delete "/posts/:id" do |id|
    post = Post[id]
    halt 404, { error: "Not found" }.to_json if post.nil?
    post.delete

    Serializers::PostBlueprint.render(post)
  end
end
