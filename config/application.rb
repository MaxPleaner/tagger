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
  c.token = ENV["MONKEY_LEARN_TOKEN"]
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

class SelfScraper
    def self.begin(company_name)
        agent = Mechanize.new # dont share the other one
        loopedy = ->(page){
            page = agent.get(page)
            links = page.css(".search-trigger-link").map { |link| link.attributes['href'].value }
            next_pages = links.map { |link| agent.get(link) }
            page = next_pages.sample
            next next_pages
        }
        while true
            pages_options ||= []
            begin
                page ||= "http://localhost:3000/?category_name=linkedin&category_argument=#{company_name}"
                pages_options = loopedy.call(page)
                page = pages_options.sample
            rescue StandardError => e
                page = pages_options.sample
                pages_options = loopedy.call(page)
                page = pages_options.sample
            end
        end
    end
end

class LinkedInCollection
    attr_accessor :companies
    def initialize(options={})
        @companies = options[:companies] || options["companies"]
    end
end

class TagsCollection
    attr_accessor :tags
    def initialize(options={})
        @tags = options[:tags] || options["tags"]
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
    def self.create_tag(options={})
        relation_type, relation_id, title = options.values_at(:relation_type, :relation_id, :title)
        return nil unless [relation_type, relation_id, title].all?
        tag = Tag.create(relation_type: relation_type, relation_id: relation_id, title: title.downcase)
        return tag
    end

    def self.categorize(options={})
        category_name, category_argument = options.values_at(:category_name, :category_argument)
        return nil unless [category_name, category_argument].all?
        cache_record = GenericCache.find_by(category: category_name, title: category_argument)
        return nil unless cache_record
        record_attrs = YAML.load(cache_record.content)
        keywords = categories_for(text: record_attrs[:description])
        tags = YAML.load(keywords).map { |word| create_tag(relation_type: "generic_cache", relation_id: cache_record.id, title: word)}
        record_attrs[:source] && cache_record.update(
            content: YAML.dump(
                record_attrs.merge(:categories => tags)
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
