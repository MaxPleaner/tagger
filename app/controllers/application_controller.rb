class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  http_basic_authenticate_with(name: ENV["AUTH_NAME"], password: ENV["AUTH_PASSWORD"])

  def agent
    @agent ||= Mechanize.new
  end

  def categorize_and_perform_request(options={})
    category_name = options[:category_name]
    category_argument = options[:category_argument]
    return nil unless [:category_name, :category_argument].all?
    case category_name
    when "linkedin"
      url =  "https://www.linkedin.com/company/#{category_argument}"
      page = agent.get(url)
      obj = LinkedInCollection.new(
        companies: page.css("#extra > div.also-viewed.module > ul > li > a").map { |related_company|
          title = related_company.attributes['title'].to_s.downcase.gsub(' ', '-')
          cached = Cache.company(title)
          next cached if cached
          related_company_url = related_company.attributes['href'].to_s 
          related_link = "#{ROOT_URL}/?category_name=linkedin&category_argument=#{title}"
          related_company_page = agent.get(related_company_url)
          description = related_company_page.css(
            "#content > div.basic-info.viewmore-container.abbreviated > div.basic-info-description > p"
          ).to_s
          location = related_company_page.css(
            "#content > div.basic-info > div.basic-info-about > ul > li.vcard.hq > .adr"
          ).to_s
          # binding.pry
          company = {
            href: related_link,
            title: title,
            description: description,
            location: location
          }
          Cache.store_company(company)
          next company
        }.flatten
      )
    else
      return nil, nil
    end
    return [url, obj]
  end

end
