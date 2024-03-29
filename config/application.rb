require_relative 'boot'

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module LdpdHours
  class Application < Rails::Application
    include Cul::Omniauth::FileConfigurable
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 6.1
    config.autoload_paths += %W(#{config.root}/lib)

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration can go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded after loading
    # the framework and any gems in your application.
    config.action_dispatch.rescue_responses.merge! 'CanCan::AccessDenied' => :forbidden

    config.time_zone = 'Eastern Time (US & Canada)'
  end
end
