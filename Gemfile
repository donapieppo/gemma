source "https://rubygems.org"
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

gem "dm_unibo_user_search", git: "https://github.com/donapieppo/dm_unibo_user_search.git"
gem "dm_unibo_common", git: "https://github.com/donapieppo/dm_unibo_common.git", branch: "master"
# gem "dm_unibo_common", path: "/home/rails/gems/dm_unibo_common/"

gem "puma"

gem "jsbundling-rails"
gem "cssbundling-rails"

gem "chunky_png"
gem "barby"
gem "image_processing"

gem "prawn"
gem "prawn-table"
gem "prawn-labels"

gem "aws-sdk-s3", require: false

# gem 'sprockets-rails', "=3.4.2", require: 'sprockets/railtie'
gem "sprockets-rails"
gem "omniauth-rails_csrf_protection"

gem "bootsnap", require: false

gem "lograge"

group :development, :test do
  gem "rspec-rails", "~> 6.0.0"
  gem "factory_bot_rails"
  # gem "faker"
end

group :development do
  # Use console on exceptions pages [https://github.com/rails/web-console]
  # gem "web-console"

  # Add speed badges [https://github.com/MiniProfiler/rack-mini-profiler]
  # gem "rack-mini-profiler"

  # Speed up commands on slow machines / big apps [https://github.com/rails/spring]
  # gem "spring"
end

group :test do
  # Use system testing [https://guides.rubyonrails.org/testing.html#system-testing]
  gem "capybara"
  gem "selenium-webdriver"
  gem "webdrivers"
  gem "cucumber-rails", require: false
  gem "database_cleaner"
  gem "standard"
  gem "ruby-lsp"
  gem "ruby-lsp-rails"
end
