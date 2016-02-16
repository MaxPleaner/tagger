
require 'pry'
require 'mechanize'

# define storage
require 'pstore'
Pstore_DB = PStore.new("database.pstore")

# define Monkeylearn client
require 'monkeylearn' 
Monkeylearn.configure do |c|
  c.token = ENV["MONKEY_LEARN_TOKEN"]
end

class Scraper
  
  def self.analyze(text)
    response = Monkeylearn.classifiers.classify('cl_4PFzSWVR', [text], sandbox: false)
    # laborious parsing of monkeylearn response
    labels = response.responses.map do |response|
      JSON.parse(response.raw_response.env.body)
    end.map do |section|
      section['result']
    end.map do |group|
      group.map { |entry| entry.map { |item| item['label'] } }
    end.flatten
    return labels
  end

  def self.begin
    # define settings keys
    settings = {
      url: nil,
      link_selector: nil,
      text_selector: nil,
      interval: nil,
      safemode: false
    }
    # assign settings vals
    ARGV.each do |argv|
      key, val = argv.split("=")
      next unless [key, val].all?
      settings[key.to_sym] ||= val
    end
    if settings[:safemode]
      # return unless options given
      unless settings.values.all?
        puts "provide url, link_selector, text_selector, and interval options"
        exit
      end
    end
    # loop forever?
    links = []
    url = settings[:url]
    while true
      sleep settings[:interval].to_f
      puts settings[:interval].to_f
       begin
        page = Mechanize.new.get(url)
        base_url = url.split(/[^\/]\/[^\/]/)[0]
        puts "base url=#{base_url}"
        links = page.css(settings[:link_selector]).map do |link|
          url_val = link.attributes['href'].value
          chars = url_val.chars
          if chars[0..1] == "//"
            2.times { chars.shift }
            url_val = "http://#{chars.join}"
          elsif chars[0] == "/"
            chars.shift
            url_val = "#{url}#{chars.join}"
          end
          url_val
        end
        text = page.css(settings[:text_selector])
        puts analyze(text.inner_html)
        puts url
        links.to_a.delete_if { |link| (link =~ /#/) || !(link =~ /\/\//) || !link }
        url = links.to_a.sample 
      rescue StandardError => e
        binding.pry
        url = links.to_a.sample
      end
    end
  end # self.begin

end # Scraper class

