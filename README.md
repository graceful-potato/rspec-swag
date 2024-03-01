<!-- cspell:ignore allof anyof oneof specifyingtesting -->

rspec-swag
=========

OpenApi 3.0 and Swagger 2.0 compatible!

This is a fork of the [rswag-specs](https://github.com/rswag/rswag/tree/master/rswag-specs) gem. The original **rswag-specs** gem is designed specifically for Rails applications, but this fork can be utilized with any Ruby rack-compatible framework. Essentially, it uses `rack-test` instead of `ActionDispatch::IntegrationTest`.

rspec-swag extends rspec "request specs" with a Swagger-based DSL for describing and testing API operations. You describe your API operations with a succinct, intuitive syntax, and it automatically runs the tests. Once you have green tests, run a rake task to auto-generate corresponding Swagger files. This gem makes it seamless to go from integration specs, which you're probably doing in some form already, to documentation for your API consumers.

And that's not all ...

Once you have an API that can describe itself in Swagger, you've opened the treasure chest of Swagger-based tools including a client generator that can be targeted to a wide range of popular platforms. See [swagger-codegen](https://github.com/swagger-api/swagger-codegen) for more details.

<!-- START doctoc generated TOC please keep comment here to allow auto update -->
**Table of Contents**

- [rspec-swag](#rspec-swag)
  - [Compatibility](#compatibility)
  - [Getting Started](#getting-started)
  - [The rspec DSL](#the-rspec-dsl)
    - [Paths, Operations and Responses](#paths-operations-and-responses)
    - [Null Values](#null-values)
    - [Support for oneOf, anyOf or AllOf schemas](#support-for-oneof-anyof-or-allof-schemas)
    - [Global Metadata](#global-metadata)
      - [Supporting multiple versions of API](#supporting-multiple-versions-of-api)
      - [Formatting the description literals:](#formatting-the-description-literals)
    - [Specifying/Testing API Security](#specifyingtesting-api-security)
  - [Configuration & Customization](#configuration--customization)
    - [Output Location for Generated Swagger Files](#output-location-for-generated-swagger-files)
    - [Input Location for Rspec Tests](#input-location-for-rspec-tests)
    - [Referenced Parameters and Schema Definitions](#referenced-parameters-and-schema-definitions)
    - [Request examples](#request-examples)
    - [Response headers](#response-headers)
      - [Nullable or Optional Response Headers](#nullable-or-optional-response-headers)
    - [Response examples](#response-examples)
    - [Enable auto generation examples from responses](#enable-auto-generation-examples-from-responses)
      - [Dry Run Option](#dry-run-option)
      - [Running tests without documenting](#running-tests-without-documenting)
    - [Custom :getter option for parameter](#custom-getter-option-for-parameter)
    - [Linting with RuboCop RSpec](#linting-with-rubocop-rspec)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

## Compatibility ##

- any rack compatible web framework (**Sinatra**, **Padrino**, **Hanami**, **Roda**, etc.)
- rspec > 3.0
- rack-test

## Getting Started ##

1. Make sure that the _rspec_ gem is installed and initialized. If not add this to your applications _Gemfile_:

    ```ruby
    group :development, :test do
      # ...
      gem "rspec"
    end
    ```

    Run

    ```sh
    bundle install
    ```

    and then

    ```sh
    rspec --init
    ```

2. Make sure that the _rack-test_ gem is installed and configured correctly. Some frameworks, such as Hanami, come with it out of the box. If not add _rack-test_ to your applications _Gemfile_:

    ```ruby
    group :development, :test do
      # ...
      gem "rack-test"
    end
    ```

    After that you need to include `Rack::Test::Methods` and define `app` method in your _spec/spec_helper.rb_ file. Modify it this way:

    ```ruby
    require "rack/test"
    # ...
    RSpec.configure do |config|
      config.include Rack::Test::Methods
      # ...
    end

    # This method should return the class of your application that you run
    # in your 'config.ru' file. The Rack::Test mock request methods send
    # requests to the return value of a method named app.
    #
    # For example, if you are installing this gem in a Sinatra modular
    # application, simply set the app method to return your specific class.
    #
    #   def app
    #     MySinatraApp
    #   end
    #
    # If you’re using a classic style Sinatra application, then you need to
    # return an instance of Sinatra::Application.
    #
    #   def app
    #     Sinatra::Application
    #   end
    #
    # Also, ensure that you require your main application file:
    #   require_relative "../app.rb"
    def app
      # return class of the application
    end
    ```

3. Add _rspec-swag_ gem to your applications _Gemfile_:

    ```ruby
    group :development, :test do
      # ...
      gem "rspec-swag"
    end
    ```

4. Add this line to your applications _Rakefile_. If you don't have one, then just create it:

    ```ruby
    require "rspec/swag/rake_task"
    ```

5. Run bundle install in application folder:

    ```sh
    bundle install
    ```

6. Run the install generator:

    ```sh
    rake rspec:swag:install
    ```

7. Create an integration spec to describe and test your API:

    ```ruby
    # spec/requests/blogs_spec.rb
    require "swagger_helper"

    RSpec.describe "Blogs API", type: :request do
      path "/blogs" do

        post "Creates a blog" do
          tags "Blogs"
          consumes "application/json"
          parameter name: :blog, in: :body, schema: {
            type: :object,
            properties: {
              title: { type: :string },
              content: { type: :string }
            },
            required: [ "title", "content" ]
          }

          response "201", "blog created" do
            let(:blog) { { title: "foo", content: "bar" } }
            run_test!
          end

          response "422", "invalid request" do
            let(:blog) { { title: "foo" } }
            run_test!
          end
        end
      end

      path "/blogs/{id}" do

        get "Retrieves a blog" do
          tags "Blogs", "Another Tag"
          produces "application/json", "application/xml"
          parameter name: :id, in: :path, type: :string
          request_body_example value: { some_field: "Foo" }, name: "basic", summary: "Request example description"

          response "200", "blog found" do
            schema type: :object,
              properties: {
                id: { type: :integer },
                title: { type: :string },
                content: { type: :string }
              },
              required: [ "id", "title", "content" ]

            let(:id) { Blog.create(title: "foo", content: "bar").id }
            run_test!
          end

          response "404", "blog not found" do
            let(:id) { "invalid" }
            run_test!
          end

          response "406", "unsupported accept header" do
            let(:"Accept") { "application/foo" }
            run_test!
          end
        end
      end
    end
    ```

8. Generate the Swagger JSON file(s)

    ```ruby
    rake rspec:swaggerize
    ```

## The rspec DSL ##

### Paths, Operations and Responses ###

If you've used [Swagger](http://swagger.io/specification) before, then the syntax should be very familiar. To describe your API operations, start by specifying a path and then list the supported operations (i.e. HTTP verbs) for that path. Path parameters must be surrounded by curly braces ({}). Within an operation block (see "post" or "get" in the example above), most of the fields supported by the [Swagger "Operation" object](http://swagger.io/specification/#operationObject) are available as methods on the example group. To list (and test) the various responses for an operation, create one or more response blocks. Again, you can reference the [Swagger "Response" object](http://swagger.io/specification/#responseObject) for available fields.

Take special note of the __run_test!__ method that's called within each response block. This tells rspec-swag to create and execute a corresponding example. It builds and submits a request based on parameter descriptions and corresponding values that have been provided using the rspec "let" syntax. For example, the "post" description in the example above specifies a "body" parameter called "blog". It also lists 2 different responses. For the success case (i.e. the 201 response), notice how "let" is used to set the blog parameter to a value that matches the provided schema. For the failure case (i.e. the 422 response), notice how it's set to a value that does not match the provided schema. When the test is executed, rspec-swag also validates the actual response code and, where applicable, the response body against the provided [JSON Schema](https://json-schema.org/specification).

If you want to add metadata to the example, you can pass keyword arguments to the __run_test!__ method:

```ruby
# to run particular test case
response '201', 'blog created' do
  run_test! focus: true
end

# to write vcr cassette
response '201', 'blog created' do
  run_test! vcr: true
end
```

If you want to customize the description of the generated specification, a description can be passed to **run_test!**

```ruby
response '201', 'blog created' do
  run_test! "custom spec description"
end
```

If you want to do additional validation on the response, pass a block to the __run_test!__ method:

```ruby
response '201', 'blog created' do
  run_test! do |response|
    data = JSON.parse(response.body)
    expect(data['title']).to eq('foo')
  end
end
```

If you'd like your specs to be a little more explicit about what's going on here, you can replace the call to __run_test!__ with equivalent "before" and "it" blocks:

```ruby
response '201', 'blog created' do
  let(:blog) { { title: 'foo', content: 'bar' } }

  before do |example|
    submit_request(example.metadata)
  end

  it 'returns a valid 201 response' do |example|
    assert_response_matches_metadata(example.metadata)
  end
end
```

Also note that the examples generated with __run_test!__ are tagged with the `:swagger` so they can easily be filtered. E.g. `rspec --tag swagger`

### date-time in query parameters

Input sent in queries of Rspec tests is HTML safe, including date-time strings.

```ruby
parameter name: :date_time, in: :query, type: :string

response '200', 'blog found' do
  let(:date_time) { DateTime.new(2001, 2, 3, 4, 5, 6, '-7').to_s }

  run_test! do
    expect(request[:path]).to eq('/blogs?date_time=2001-02-03T04%3A05%3A06-07%3A00')
  end
end
```

### Strict schema validation

By default, if response body contains undocumented properties tests will pass. To keep your responses clean and validate against a strict schema definition you can set the global config option:

```ruby
# spec/swagger_helper.rb
RSpec.configure do |config|
  config.openapi_strict_schema_validation = true
end
```

or set the option per individual example:

```ruby
# using in run_test!
describe 'Blogs API' do
  path '/blogs' do
    post 'Creates a blog' do
      ...
      response '201', 'blog created' do
        let(:blog) { { title: 'foo', content: 'bar' } }

        run_test!(openapi_strict_schema_validation: true)
      end
    end
  end
end

# using in response block
describe 'Blogs API' do
  path '/blogs' do
    post 'Creates a blog' do
      ...

      response '201', 'blog created', openapi_strict_schema_validation: true do
        let(:blog) { { title: 'foo', content: 'bar' } }

        run_test!
      end
    end
  end
end

# using in an explicit example
describe 'Blogs API' do
  path '/blogs' do
    post 'Creates a blog' do
      ...
      response '201', 'blog created' do
        let(:blog) { { title: 'foo', content: 'bar' } }

        before do |example|
          submit_request(example.metadata)
        end

        it 'returns a valid 201 response', openapi_strict_schema_validation: true do |example|
          assert_response_matches_metadata(example.metadata)
        end
      end
    end
  end
end
```

### Null Values ###

This library is currently using JSON::Draft4 for validation of response models. Nullable properties can be supported with the non-standard property 'x-nullable' to a definition to allow null/nil values to pass. Or you can add the new standard ```nullable``` property to a definition.
```ruby
describe 'Blogs API' do
  path '/blogs' do
    post 'Creates a blog' do
      ...

      response '200', 'blog found' do
        schema type: :object,
          properties: {
            id: { type: :integer },
            title: { type: :string, nullable: true }, # preferred syntax
            content: { type: :string, 'x-nullable': true } # legacy syntax, but still works
          }
        ....
      end
    end
  end
end
```

### Support for oneOf, anyOf or AllOf schemas ###

Open API 3.0 now supports more flexible schema validation with the ```oneOf```, ```anyOf``` and ```allOf``` directives. rspec-swag will handle these definitions and validate them properly.


Notice the ```schema``` inside the ```response``` section. Placing a ```schema``` method inside the response will validate (and fail the tests)
if during the integration test run the endpoint response does not match the response schema. This test validation can handle anyOf and allOf as well. See below:

```ruby

  path '/blogs/flexible' do
    post 'Creates a blog flexible body' do
      tags 'Blogs'
      description 'Creates a flexible blog from provided data'
      operationId 'createFlexibleBlog'
      consumes 'application/json'
      produces 'application/json'

      parameter name: :blog, in: :body, schema: {
          oneOf: [
            { '$ref' => '#/components/schemas/blog' },
            { '$ref' => '#/components/schemas/flexible_blog' }
          ]
        }

      response '201', 'flexible blog created' do
        schema oneOf: [{ '$ref' => '#/components/schemas/blog' }, { '$ref' => '#/components/schemas/flexible_blog' }]
        run_test!
      end
    end
  end

```
This automatic schema validation is a powerful feature of rspec-swag.

### Global Metadata ###

In addition to paths, operations and responses, Swagger also supports global API metadata. When you install rspec-swag, a file called _swagger_helper.rb_ is added to your spec folder. This is where you define one or more Swagger documents and provide global metadata. Again, the format is based on Swagger so most of the global fields supported by the top level ["Swagger" object](http://swagger.io/specification/#swaggerObject) can be provided with each document definition. As an example, you could define a Swagger document for each version of your API and in each case specify a title, version string. In Open API 3.0 the pathing and server definitions have changed a bit [Swagger host/basePath](https://swagger.io/docs/specification/api-host-and-base-path/):

```ruby
# spec/swagger_helper.rb
RSpec.configure do |config|
  config.openapi_root = File.expand_path("../", File.dirname(__FILE__))

  config.openapi_specs = {
    'v1/swagger.json' => {
      openapi: '3.0.1',
      info: {
        title: 'API V1',
        version: 'v1',
        description: 'This is the first version of my API'
      },
      servers: [
        {
          url: 'https://{defaultHost}',
          variables: {
            defaultHost: {
                default: 'www.example.com'
            }
          }
        }
      ]
    },

    'v2/swagger.json' => {
      openapi: '3.0.1',
      info: {
        title: 'API V2',
        version: 'v2',
        description: 'This is the second version of my API'
      },
      servers: [
        {
          url: '{protocol}://{defaultHost}',
          variables: {
            protocol: {
              default: :https
            },
            defaultHost: {
                default: 'www.example.com'
            }
          }
        }
      ]
    }
  }
end
```

#### Supporting multiple versions of API ####
By default, the paths, operations and responses defined in your spec files will be associated with the first Swagger document in _swagger_helper.rb_. If your API has multiple versions, you should be using separate documents to describe each of them. In order to assign a file with a given version of API, you'll need to add the ```openapi_spec``` tag to each spec specifying its target document name:

```ruby
# spec/requests/v2/blogs_spec.rb
describe 'Blogs API', openapi_spec: 'v2/swagger.yaml' do

  path '/blogs' do
  ...

  path '/blogs/{id}' do
  ...
end
```

#### Supporting YAML format ####

By default, the swagger docs are generated in JSON format. If you want to generate them in YAML format, you can specify the swagger format in the swagger_helper.rb file:

```ruby
# spec/swagger_helper.rb
RSpec.configure do |config|
  config.openapi_root = File.expand_path("../", File.dirname(__FILE__))
  
  # Use if you want to see which test is running
  # config.formatter = :documentation

  # Generate swagger docs in YAML format
  config.openapi_format = :yaml

  config.openapi_specs = {
    'v1/swagger.yaml' => {
      openapi: '3.0.1',
      info: {
        title: 'API V1',
        version: 'v1',
        description: 'This is the first version of my API'
      },
      servers: [
        {
          url: 'https://{defaultHost}',
          variables: {
            defaultHost: {
                default: 'www.example.com'
            }
          }
        }
      ]
    },
  }
end
```

#### Formatting the description literals: ####
Swagger supports the Markdown syntax to format strings. This can be especially handy if you were to provide a long description of a given API version or endpoint. Use [this guide](https://github.com/adam-p/markdown-here/wiki/Markdown-Cheatsheet) for reference.

__NOTE:__ There is one difference between the official Markdown syntax and Swagger interpretation, namely tables. To create a table like this:

| Column1 | Column2 |
| ------- | ------- |
| cell1   | cell2   |

you should use the following syntax, making sure there is no whitespace at the start of any of the lines:

```
&#13;
| Column1 | Column2 | &#13; |
| ------- | ------- |&#13;
| cell1   | cell2    |&#13;
&#13;
```

### Specifying/Testing API Security ###

Swagger allows for the specification of different security schemes and their applicability to operations in an API.
To leverage this in rspec-swag, you define the schemes globally in _swagger_helper.rb_ and then use the "security" attribute at the operation level to specify which schemes, if any, are applicable to that operation.
Swagger supports :basic, :bearer, :apiKey and :oauth2 and :openIdConnect scheme types. See [the spec](https://swagger.io/docs/specification/authentication/) for more info, as this underwent major changes between Swagger 2.0 and Open API 3.0

```ruby
# spec/swagger_helper.rb
RSpec.configure do |config|
  config.openapi_root = File.expand_path("../", File.dirname(__FILE__))

  config.openapi_specs = {
    'v1/swagger.json' => {
      ...  # note the new Open API 3.0 compliant security structure here, under "components"
      components: {
        securitySchemes: {
          basic_auth: {
            type: :http,
            scheme: :basic
          },
          api_key: {
            type: :apiKey,
            name: 'api_key',
            in: :query
          }
        }
      }
    }
  }
end

# spec/requests/blogs_spec.rb
describe 'Blogs API' do

  path '/blogs' do

    post 'Creates a blog' do
      tags 'Blogs'
      security [ basic_auth: [] ]
      ...

      response '201', 'blog created' do
        let(:Authorization) { "Basic #{::Base64.strict_encode64('jsmith:jspass')}" }
        run_test!
      end

      response '401', 'authentication failed' do
        let(:Authorization) { "Basic #{::Base64.strict_encode64('bogus:bogus')}" }
        run_test!
      end
    end
  end
end

# example of documenting an endpoint that handles basic auth and api key based security
describe 'Auth examples API' do
  path '/auth-tests/basic-and-api-key' do
    post 'Authenticates with basic auth and api key' do
      tags 'Auth Tests'
      operationId 'testBasicAndApiKey'
      security [{ basic_auth: [], api_key: [] }]

      response '204', 'Valid credentials' do
        let(:Authorization) { "Basic #{::Base64.strict_encode64('jsmith:jspass')}" }
        let(:api_key) { 'foobar' }
        run_test!
      end

      response '401', 'Invalid credentials' do
        let(:Authorization) { "Basic #{::Base64.strict_encode64('jsmith:jspass')}" }
        let(:api_key) { 'bar-foo' }
        run_test!
      end
    end
  end
end


```

__NOTE:__ Depending on the scheme types, you'll be required to assign a corresponding parameter value with each example.
For example, :basic auth is required above and so the :Authorization (header) parameter must be set accordingly

### Output Location for Generated Swagger Files ###

You can adjust this in the _swagger_helper.rb_ that's installed with __rspec-swag__:

```ruby
# spec/swagger_helper.rb
RSpec.configure do |config|
  config.openapi_root = File.expand_path("../your-custom-folder-name", File.dirname(__FILE__))
  ...
end
```

### Input Location for Rspec Tests ###

By default, rspec-swag will search for integration tests in _spec/requests_, _spec/api_ and _spec/integration_. If you want to use tests from other locations, provide the PATTERN argument to rake:

```ruby
# search for tests in spec/swagger
rake rspec:swaggerize PATTERN="spec/swagger/**/*_spec.rb"
```

### Additional rspec options

You can add additional rspec parameters using the ADDITIONAL_RSPEC_OPTS env variable:

```ruby
# Only include tests tagged "swagger"
rake rspec:swaggerize ADDITIONAL_RSPEC_OPTS="--tag swagger"
```

### Referenced Parameters and Schema Definitions ###

Swagger allows you to describe JSON structures inline with your operation descriptions OR as referenced globals.
For example, you might have a standard response structure for all failed operations.
Again, this is a structure that changed since swagger 2.0. Notice the new "schemas" section for these.
Rather than repeating the schema in every operation spec, you can define it globally and provide a reference to it in each spec:

```ruby
# spec/swagger_helper.rb
config.openapi_specs = {
  'v1/swagger.json' => {
    openapi: '3.0.0',
    info: {
      title: 'API V1'
    },
    components: {
      schemas: {
        errors_object: {
          type: 'object',
          properties: {
            errors: { '$ref' => '#/components/schemas/errors_map' }
          }
        },
        errors_map: {
          type: 'object',
          additionalProperties: {
            type: 'array',
            items: { type: 'string' }
          }
        },
        blog: {
          type: 'object',
          properties: {
            id: { type: 'integer' },
            title: { type: 'string' },
            content: { type: 'string', nullable: true },
            thumbnail: { type: 'string', nullable: true }
          },
          required: %w[id title]
        },
        new_blog: {
          type: 'object',
          properties: {
            title: { type: 'string' },
            content: { type: 'string', nullable: true },
            thumbnail: { type: 'string', format: 'binary', nullable: true }
          },
          required: %w[title]
        }
      }
    }
  }
}

# spec/requests/blogs_spec.rb
describe 'Blogs API' do

  path '/blogs' do

    post 'Creates a blog' do

      parameter name: :new_blog, in: :body, schema: { '$ref' => '#/components/schemas/new_blog' }

      response 422, 'invalid request' do
        schema '$ref' => '#/components/schemas/errors_object'
  ...
end

# spec/requests/comments_spec.rb
describe 'Blogs API' do

  path '/blogs/{blog_id}/comments' do

    post 'Creates a comment' do

      response 422, 'invalid request' do
        schema '$ref' => '#/components/schemas/errors_object'
  ...
end
```

### Request examples ###

```ruby
# spec/integration/blogs_spec.rb
describe 'Blogs API' do

  path '/blogs/{blog_id}' do

    get 'Retrieves a blog' do

      request_body_example value: { some_field: 'Foo' }, name: 'request_example_1', summary: 'A request example'

      response 200, 'blog found' do
        ...
```

to use the actual request from the spec as the example:

```ruby
config.after(:each, operation: true, use_as_request_example: true) do |spec|
  spec.metadata[:operation][:request_examples] ||= []

  example = {
    value: JSON.parse(request.body.string, symbolize_names: true),
    name: 'request_example_1',
    summary: 'A request example'
  }

  spec.metadata[:operation][:request_examples] << example
end
```

### Response headers ###

In rspec-swag, you could use `header` method inside the response block to specify header objects for this response.
rspec-swag will validate your response headers with those header objects and inject them into the generated swagger file:

```ruby
# spec/requests/comments_spec.rb
describe 'Blogs API' do

  path '/blogs/{blog_id}/comments' do

    post 'Creates a comment' do

      response 422, 'invalid request' do
        header 'X-Rate-Limit-Limit', schema: { type: :integer }, description: 'The number of allowed requests in the current period'
        header 'X-Rate-Limit-Remaining', schema: { type: :integer }, description: 'The number of remaining requests in the current period'
  ...
end
```

#### Nullable or Optional Response Headers ####

You can include `nullable` or `required` to specify whether a response header must be present or may be null. When `nullable` is not included, the headers validation validates that the header response is non-null. When `required` is not included, the headers validation validates the the header response is passed.

```ruby
# spec/integration/comments_spec.rb
describe 'Blogs API' do

  path '/blogs/{blog_id}/comments' do

    get 'Gets a list of comments' do

      response 200, 'blog found' do
        header 'X-Cursor', schema: { type: :string, nullable: true }, description: 'The cursor to get the next page of comments.'
        header 'X-Per-Page', schema: { type: :integer }, required: false, description: 'The number of comments per page.'
  ...
end
```

### Response examples ###

You can provide custom response examples to the generated swagger file by calling the method `examples` inside the response block:
However, auto generated example responses are now enabled by default in rspec-swag. See below.

```ruby
# spec/requests/blogs_spec.rb
describe 'Blogs API' do

  path '/blogs/{blog_id}' do

    get 'Retrieves a blog' do

      response 200, 'blog found' do
        example 'application/json', :example_key, {
            id: 1,
            title: 'Hello world!',
            content: '...'
          }
        example 'application/json', :example_key_2, {
            id: 1,
            title: 'Hello world!',
            content: '...'
          }, "Summary of the example", "Longer description of the example"
  ...
end
```


### Enable auto generation examples from responses ###


To enable examples generation from responses add callback above run_test! like:

```ruby
after do |example|
  content = example.metadata[:response][:content] || {}
  example_spec = {
    "application/json"=>{
      examples: {
        test_example: {
          value: JSON.parse(response.body, symbolize_names: true)
        }
      }
    }
  }
  example.metadata[:response][:content] = content.deep_merge(example_spec)
end
```

#### Dry Run Option ####

The `--dry-run` option is enabled by default for Rspec 3, but if you need to
disable it you can use the environment variable `SWAGGER_DRY_RUN=0` during the
generation command or add the following to your `config/environments/test.rb`:

```ruby
RSpec.configure do |config|
  config.swagger_dry_run = false
end
```

#### Running tests without documenting ####

If you want to use rspec-swag for testing without adding it to you swagger docs, you can provide the document tag:
```ruby
describe 'Blogs API' do
  path '/blogs/{blog_id}' do
    get 'Retrieves a blog' do
      # documentation is now disabled for this response only
      response 200, 'blog found', document: false do
        ...
```

You can also reenable documentation for specific responses only:
```ruby
# documentation is now disabled
describe 'Blogs API', document: false do
  path '/blogs/{blog_id}' do
    get 'Retrieves a blog' do
      # documentation is reenabled for this response only
      response 200, 'blog found', document: true do
        ...
      end

      response 401, 'special case' do
        ...
      end
```

### Custom :getter option for parameter

To avoid conflicts with `status` method and other possible intersections:

```ruby
...
parameter name: :status,
          getter: :filter_status,
          in: :query,
          schema: {
            type: :string,
            enum: %w[one two three],
          }, required: false

let(:status) { nil } # will not be used in query string
let(:filter_status) { 'one' } # `&status=one` will be provided in final query
```

### Linting with RuboCop RSpec

When you lint your RSpec spec files with `rubocop-rspec`, it will fail to detect RSpec aliases that rspec-swag defines.
Make sure to use `rubocop-rspec` 2.0 or newer and add the following to your `.rubocop.yml`:

```yaml
inherit_gem:
  rspec-swag: .rubocop_rspec_alias_config.yml
```
