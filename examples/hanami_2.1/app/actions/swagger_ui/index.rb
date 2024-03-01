# frozen_string_literal: true

module Blog::Actions::SwaggerUi
  class Index < Blog::Action
    def handle(request, response)
      response.render view, layout: false
    end
  end
end
