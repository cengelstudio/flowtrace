source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '3.2.8'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails', branch: 'main'
gem 'rails', '~> 7.1.0'
gem 'logger'

# The original asset pipeline for Rails [https://github.com/rails/sprockets-rails]
gem 'sprockets-rails', '>= 3.4.0'

# Use postgresql as the database for Active Record
gem 'pg', '~> 1.1'

# Use the Puma web server [https://github.com/puma/puma]
gem 'puma', '~> 6.0'

# Bundle and transpile JavaScript [https://github.com/rails/jsbundling-rails]
gem 'jsbundling-rails'

# Hotwire's SPA-like page accelerator [https://turbo.hotwired.dev]
gem 'turbo-rails'

# Hotwire's modest JavaScript framework [https://stimulus.hotwired.dev]
gem 'stimulus-rails'

# Build JSON APIs with ease [https://github.com/rails/jbuilder]
gem 'jbuilder'

# Use Redis adapter to run Action Cable in production
gem 'redis', '~> 4.0'

# Use Kredis to get higher-level data types in Redis [https://github.com/rails/kredis]
# gem 'kredis'

# Use Active Model has_secure_password [https://guides.rubyonrails.org/active_model_basics.html#securepassword]
gem 'bcrypt', '~> 3.1.7'

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: %i[ mingw mswin x64_mingw jruby ]

# Reduces boot times through caching; required in config/boot.rb
gem 'bootsnap', '>= 1.4.4', require: false

# Use Sass to process CSS
gem 'sassc-rails'

# Use image processing with mini_magick
gem 'image_processing', '~> 1.2'

# Authentication
gem 'devise'

# Authorization
gem 'pundit'

# QR Code generation
gem 'rqrcode'

# PDF generation
gem 'prawn'
gem 'prawn-svg'

# CORS handling
gem 'rack-cors'

# API versioning
gem 'versionist'

# Search functionality
gem 'pg_search'

# Background jobs
gem 'sidekiq'

# Serialization
gem 'active_model_serializers'

# Environment variables
gem 'dotenv-rails'

# Pagination
gem 'kaminari'

# UUID generation
gem 'securerandom'

group :development, :test do
  # See https://guides.rubyonrails.org/debugging_rails_applications.html#debugging-with-the-debug-gem
  gem 'debug', platforms: %i[ mri mingw x64_mingw ]

  # Testing framework
  gem 'rspec-rails'
  gem 'factory_bot_rails'
  gem 'faker'

  # Code quality
  gem 'rubocop', require: false
  gem 'rubocop-rails', require: false
  gem 'rubocop-rspec', require: false
end

group :development do
  # Use console on exceptions pages [https://github.com/rails/web-console]
  gem 'web-console'

  # Speed up commands on slow machines / big apps [https://github.com/rails/spring]
  gem 'spring'

  # Database tools
  gem 'annotate'

  # File change listening
  gem 'listen'
end

group :test do
  gem 'shoulda-matchers'
  gem 'database_cleaner-active_record'
end
