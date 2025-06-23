require_relative "boot"

require "rails/all"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Flowtrace
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 7.0

    # Configuration for the application, engines, and railties goes here.
    #
    # These settings can be overridden in specific environments using the files
    # in config/environments/, which are processed later.
    #
    # config.time_zone = "Central Time (US & Canada)"
    # config.eager_load_paths << Rails.root.join("extras")

    # API configuration
    config.api_only = false

    # CORS configuration
    config.middleware.insert_before 0, Rack::Cors do
      allow do
        origins '*'
        resource '*',
          headers: :any,
          methods: [:get, :post, :put, :patch, :delete, :options, :head]
      end
    end

    # Time zone
    config.time_zone = 'Istanbul'

    # Locale
    config.i18n.default_locale = :tr
    config.i18n.available_locales = [:tr, :en]

    # Auto-load lib directory
    config.autoload_paths << Rails.root.join('lib')

    # Allow modern browsers only
    config.force_ssl = false # Set to true in production

    # Generator configuration
    config.generators do |g|
      g.test_framework :rspec
      g.factory_bot_dir 'spec/factories'
      g.fixture_replacement :factory_bot
      g.stylesheets false
      g.javascripts false
      g.helper false
    end
  end
end
