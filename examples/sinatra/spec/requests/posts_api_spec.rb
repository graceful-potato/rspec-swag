# frozen_string_literal: true

require "swagger_helper"

RSpec.describe "Posts API" do
  path "/posts" do
    get "Retrieves all posts" do
      tags "Posts"
      consumes "application/json"
      produces "application/json"

      response "200", "successful" do
        schema type: :array,
          items: {
            type: :object,
            properties: {
                 id: { type: :integer },
                 title: { type: :string },
                 body: { type: :string },
                 created_at: { type: :string },
                 updated_at: { type: :string, nullable: true }
               },
               required: %w[id title body created_at updated_at],
               additionalProperties: false
          }

        let!(:post1) { Post.create(title: "title1", body: "body1") }
        let!(:post2) { Post.create(title: "title2", body: "body2") }

        run_test! do |response|
          expect(JSON.parse(response.body)).to match [
            a_hash_including("title" => post1.title, "body" => post1.body),
            a_hash_including("title" => post2.title, "body" => post2.body)
          ]
        end
      end
    end

    post "Creates a post" do
      tags "Posts"
      consumes "application/json"
      produces "application/json"
      parameter name: :data, in: :body, schema: {
        type: :object,
        properties: {
          title: { type: :string },
          body: { type: :string }
        },
        required: %w[title body]
      }

      response "201", "created" do
        schema type: :object,
               properties: {
                 id: { type: :integer },
                 title: { type: :string },
                 body: { type: :string },
                 created_at: { type: :string },
                 updated_at: { type: :string, nullable: true }
               },
               required: %w[id title body created_at updated_at],
               additionalProperties: false

        let(:data) { { title: "foo", body: "bar" } }
        run_test!
      end

      response "422", "invalid request" do
        schema type: :object,
          properties: {
            error: {
              type: :object,
              properties: {
                title: {
                  type: :array,
                  items: { type: :string }
                },
                body: {
                  type: :array,
                  items: { type: :string }
                }
              }
            }
          }
        let(:data) { { title: "foo" } }
        run_test!
      end
    end
  end

  path "/posts/{id}" do
    get "Retrieves a post" do
      tags "Posts"
      consumes "application/json"
      produces "application/json"
      parameter name: :id, in: :path, type: :string

      response "200", "post found" do
        schema type: :object,
               properties: {
                 id: { type: :integer },
                 title: { type: :string },
                 body: { type: :string },
                 created_at: { type: :string },
                 updated_at: { type: :string, nullable: true }
               },
               required: %w[id title body created_at updated_at],
               additionalProperties: false

        let(:id) { Post.create(title: "foo", body: "bar").id }
        run_test!
      end

      response "404", "post not found" do
        schema type: :object,
          properties: {
            error: { type: :string }
          }

        let(:id) { "invalid" }
        run_test!
      end
    end

    patch "Updates a post" do
      tags "Posts"
      consumes "application/json"
      produces "application/json"
      parameter name: :id, in: :path, type: :string
      parameter name: :data, in: :body, schema: {
        type: :object,
        properties: {
          title: { type: :string },
          body: { type: :string }
        },
        required: %w[title body]
      }

      let(:new_title) { "foo" }
      let(:new_body) { "bar" }

      response "200", "ok" do
        schema type: :object,
               properties: {
                 id: { type: :integer },
                 title: { type: :string },
                 body: { type: :string },
                 created_at: { type: :string },
                 updated_at: { type: :string, nullable: true }
               },
               required: %w[id title body created_at updated_at],
               additionalProperties: false

        let(:id) { Post.create(title: "title1", body: "body1").id }
        let(:data) { { title: new_title, body: new_body } }

        run_test! do |response|
          expect(JSON.parse(response.body)["title"]).to eq(new_title)
          expect(JSON.parse(response.body)["body"]).to eq(new_body)
        end
      end

      response "404", "not found" do
        schema type: :object,
          properties: {
            error: { type: :string }
          }

        let(:id) { "invalid" }
        let(:data) { { title: new_title, body: new_body } }

        run_test!
      end
    end

    delete "Deletes a post" do
      tags "Posts"
      consumes "application/json"
      produces "application/json"
      parameter name: :id, in: :path, type: :string

      response "200", "ok" do
        schema type: :object,
               properties: {
                 id: { type: :integer },
                 title: { type: :string },
                 body: { type: :string },
                 created_at: { type: :string },
                 updated_at: { type: :string, nullable: true }
               },
               required: %w[id title body created_at updated_at],
               additionalProperties: false

        let(:id) { Post.create(title: "title1", body: "body1").id }

        run_test!
      end

      response "404", "not found" do
        schema type: :object,
          properties: {
            error: { type: :string }
          }

        let(:id) { "invalid" }

        run_test!
      end
    end
  end
end
