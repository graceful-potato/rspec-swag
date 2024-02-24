## Getting Started

1. `bundle install`
2. `bundle exec sequel -m db/migrations sqlite://db/blog_development.sqlite3`
3. `bundle exec sequel -m db/migrations sqlite://db/blog_test.sqlite3`
4. `bundle exec rspec`
5. `bundle exec rake rspec:swaggerize`
6. `rackup`
7. visit http://localhost:9292
