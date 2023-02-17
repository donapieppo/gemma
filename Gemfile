source "https://rubygems.org"
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

gem 'dm_unibo_user_search', git: 'https://github.com/donapieppo/dm_unibo_user_search.git'
gem 'dm_unibo_common',      git: 'https://github.com/donapieppo/dm_unibo_common.git', branch: 'turbo'
#gem 'dm_unibo_common',      path: '/home/rails/gems/dm_unibo_common/'

gem "sprockets-rails"
gem "jsbundling-rails"
gem "cssbundling-rails", "~> 1.1"
gem "turbo-rails"
gem "importmap-rails"

gem "chunky_png"
gem "barby"
gem "image_processing"

gem "prawn"
gem "prawn-table"
gem "prawn-labels"

group :development, :test do
  # See https://guides.rubyonrails.org/debugging_rails_applications.html#debugging-with-the-debug-gem
  gem "debug", platforms: %i[ mri mingw x64_mingw ]
end

group :development, :test do
  gem "rspec-rails", '~> 6.0.0'
  gem "factory_bot_rails"
  gem "faker"
end

group :development do
  # Use console on exceptions pages [https://github.com/rails/web-console]
  gem "web-console"

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
  gem 'cucumber-rails', require: false
  gem 'database_cleaner'
end
