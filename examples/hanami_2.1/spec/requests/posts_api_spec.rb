# frozen_string_literal: true

require "swagger_helper"

RSpec.describe "Posts API", type: :request do
  let(:repo) { app.slices[:api]["repositories.posts"] }

  path "/api/v1/posts" do
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

        let!(:post1) { repo.create(title: "title1", body: "body1") }
        let!(:post2) { repo.create(title: "title2", body: "body2") }

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
          post: {
            type: :object,
            properties: {
              title: { type: :string },
              body: { type: :string }
            }
          }
        },
        required: %w[post title body]
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

        let(:data) { { post: { title: "foo", body: "bar" } } }
        run_test!
      end

      response "422", "unprocessable entity" do
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
        let(:data) { { post: { title: "foo" } } }
        run_test!
      end
    end
  end

  path "/api/v1/posts/{id}" do
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

        let(:id) { repo.create(title: "foo", body: "bar").id }
        run_test!
      end

      response "404", "post not found" do
        schema type: :object,
          properties: {
            error: { type: :string }
          }

        let(:id) { "0123456789" }
        run_test!
      end

      response "422", "unprocessable entity" do
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
          post: {
            type: :object,
            properties: {
              title: { type: :string },
              body: { type: :string }
            }
          }
        },
        required: %w[post title body]
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

        let(:id) { repo.create(title: "title1", body: "body1").id }
        let(:data) { { post: { title: new_title, body: new_body } } }

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

        let(:id) { "0123456789" }
        let(:data) { { post: { title: new_title, body: new_body } } }

        run_test!
      end

      response "422", "unprocessable entity" do
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

        let(:id) { "invalid" }
        let(:data) { { post: {} } }
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

        let(:id) { repo.create(title: "title1", body: "body1").id }

        run_test!
      end

      response "404", "not found" do
        schema type: :object,
          properties: {
            error: { type: :string }
          }

        let(:id) { "0123456789" }

        run_test!
      end

      response "404", "not found" do
        schema type: :object,
          properties: {
            error: { type: :string }
          }

        let(:id) { "0123456789" }

        run_test!
      end

      response "422", "unprocessable entity" do
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

        let(:id) { "invalid" }
        run_test!
      end
    end
  end
end
