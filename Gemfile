source 'https://rubygems.org'

gem 'dm_unibo_user_search', git: 'https://github.com/donapieppo/dm_unibo_user_search.git'
gem 'dm_unibo_common',      path: '/home/rails/gems/dm_unibo_common/'

gem 'bootsnap', '>= 1.4.2', require: false

gem 'webpacker', '~> 5.0'

gem "prawn"
gem "prawn-table"
gem "prawn-labels"

gem 'chunky_png'

gem "barby"

gem 'image_processing'

group :development do
  gem 'listen', '~> 3.2'
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'
end

group :development, :test do
  gem 'rspec-rails', '~> 4.0.1'
  gem 'factory_bot_rails'
end

group :test do
  # Adds support for Capybara system testing and selenium driver
  gem 'capybara', '>= 2.15'
  gem 'selenium-webdriver'
  # Easy installation and use of web drivers to run system tests with browsers
  gem 'webdrivers'
  gem 'cucumber-rails', require: false
  gem 'database_cleaner'
end

