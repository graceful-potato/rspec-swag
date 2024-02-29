# frozen_string_literal: true

module Blog::Persistence::Relations
  class Posts < ROM::Relation[:sql]
    schema(:posts, infer: true)
  end
end
