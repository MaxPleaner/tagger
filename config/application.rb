require File.expand_path('../boot', __FILE__)

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

case Rails.env
when "development"
    ROOT_URL = "http://localhost:3000"
when "production"
    ROOT_URL = "https://maxp-tagger.herokuapp.com"
end

class LinkedInCollection
    attr_accessor :companies
    def initialize(options={})
        @companies = options[:companies] || options["companies"]
    end
end

class Cache
    def self.company(title)
        match = YAML.load(GenericCache.find_by(category: "company", title: title).try(:content).to_s)
        match.blank? ? nil : match
    end
    def self.store_company(attrs)
        GenericCache.find_or_initialize_by(category: "company", title: attrs[:title]).update(
            content: YAML.dump(attrs)
        )
    end
end

module Tagger
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    # config.time_zone = 'Central Time (US & Canada)'

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    # config.i18n.default_locale = :de

    # Do not swallow errors in after_commit/after_rollback callbacks.
    config.active_record.raise_in_transactional_callbacks = true
  end
end
