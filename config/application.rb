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


require 'monkeylearn' 
Monkeylearn.configure do |c|
  c.token = '24a6e5d42480dfe422118c0c1dff606b08962793'
end

# Extractor = Phrasie::Extractor.new
class Extractor
    def self.sanitize(text)
        text.gsub("\"", "'").gsub("<", " ").gsub(">", " ")
    end
    def self.lookup(text)
        response = Monkeylearn.classifiers.classify(
            'cl_4PFzSWVR',
            [text],
            sandbox: false
        )
        parse_response_sections = response.responses.map { |response| JSON.parse(response.raw_response.env.body) }
        results = parse_response_sections.map { |section| section['result'] }
        # binding.pry
        labels = results.map { |result|
            result.map { |group|
              group.map { |item|
               item['label'] 
              }
            }
        }.flatten
        return labels
    end
end

Agent = Mechanize.new

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
    def self.categorize(options={})
        category_name, category_argument = options.values_at(:category_name, :category_argument)
        return nil unless [category_name, category_argument].all?
        cache_record = GenericCache.find_by(category: category_name, title: category_argument)
        return nil unless cache_record
        record_attrs = YAML.load(cache_record.content)
        record_attrs[:source] && cache_record.update(
            content: YAML.dump(
                record_attrs.merge(:categories => categories_for(text: record_attrs[:description]))
            )
        )
        record = GenericCache.find_by(category: category_name, title: category_argument)
        return YAML.load(record.content)
    end

    def self.categories_for(options={})
        text = options[:text]
        return nil unless text
        keywords = Extractor.lookup(text)
        return YAML.dump(keywords)
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
