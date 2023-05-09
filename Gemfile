source 'https://rubygems.org'

git_source(:github) do |repo_name|
  repo_name = "#{repo_name}/#{repo_name}" unless repo_name.include?("/")
  "https://github.com/#{repo_name}.git"
end


# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '~> 7.0.0'
# Reduces boot times through caching; required in config/boot.rb
gem 'bootsnap', require: false
gem 'bigdecimal'
# Use Puma as the app server
gem 'puma', '~> 5.2'
# Use SCSS for stylesheets
gem 'sass', '~> 3.7.4'
gem 'sass-rails', '~> 5'
gem "sprockets-rails"
gem "net-ldap", '~> 0.17.1'
gem 'nokogiri', '~> 1.10.10'
# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 1.3.0'
# See https://github.com/rails/execjs#readme for more supported runtimes
# gem 'therubyracer', platforms: :ruby

# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 2.5'
# Use Redis adapter to run Action Cable in production
# gem 'redis', '~> 3.0'

# Use sqlite3 as the database for Active Record
gem "sqlite3", "~> 1.4.2"

gem 'mysql2'

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug', platforms: [:mri, :mingw, :x64_mingw]
  # Adds support for Capybara system testing and selenium driver
  gem 'capybara', '~> 3.33'
  # For testing with chromedriver
  gem 'selenium-webdriver', '~> 3.142'
  gem 'rexml', '~> 3.2', '>= 3.2.4'
  # For automatically updating chromedriver
  gem 'webdrivers', '~> 4.0', require: false
  gem 'rspec-rails', '~> 4.0'
  gem 'factory_bot_rails', ' ~> 4.0'
  gem 'simplecov',      require: false
  gem 'simplecov-lcov', require: false
  gem 'database_cleaner'
  gem 'pry'
end

group :development do
  # Access an IRB console on exception pages or by using <%= console %> anywhere in the code.
  gem 'web-console', '>= 3.3.0'
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'
  gem 'capistrano', '3.8.2'
  gem 'capistrano-rails', '~> 1.2'
  gem 'capistrano-bundler', '~> 1.1', require: false
  gem 'capistrano-rvm', '~> 0.1', require: false
  gem 'capistrano-passenger', '~> 0.1', require: false
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]

# Moved outside dev/test group to get deploy to work, known issue
gem 'listen', '~> 3.2'

# Login/auth gems
gem 'devise'
gem 'cul_omniauth', '~> 0.8.0'
gem 'cancancan', '~> 3.0'

gem 'gaffe'

gem "cul-ldap", github: "cul/cul-ldap"
