class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  # http_basic_authenticate_with(name: ENV["AUTH_NAME"], password: ENV["AUTH_PASSWORD"])

  def agent
    @agent ||= Agent
  end

  def drag_and_drop(category_argument)
    obj = <<-HTML
    <div class="container">
      <ul>
          <div data-ss-colspan="2"></div>
          <div data-ss-colspan="2"></div>
          <div data-ss-colspan="2"></div>

          <div data-ss-colspan="2"></div>
          <div data-ss-colspan="2"></div>

          <div data-ss-colspan="2"></div>
          <div data-ss-colspan="2"></div>
          <div data-ss-colspan="2"></div> 

          <div data-ss-colspan="2"></div>
          <div data-ss-colspan="2"></div>

          <div data-ss-colspan="2"></div>
          <div data-ss-colspan="2"></div>
      </ul>    
    </div>
    HTML
    return [ROOT_URL, DragAndDropInterface.new(html: obj)]
  end

  def linkedin_query(category_argument)
      url =  "https://www.linkedin.com/company/#{category_argument}"
      page = agent.get(url)
      obj = LinkedInCollection.new(
        companies: page.css("#extra > div.also-viewed.module > ul > li > a").map { |related_company|
          title = related_company.attributes['title'].to_s.downcase.gsub(' ', '-').gsub("&", "-")
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
          company = {
            href: related_link,
            source: related_company_url,
            title: title,
            description: description,
            location: location
          }
          Cache.store_company(company)
          company = Cache.categorize(category_name: "company", category_argument: company[:title])
          puts "#{"Categorized #{company[:title]}".black_on_green} - #{company[:categories].map { |tag| tag["title"] }}"
          sleep 2
          next company
        }.flatten
      )
      return [url, obj]
  end

  def tag_details(category_argument)
    url = "#{ROOT_URL}/?tag_details=#{category_argument}"
    tags = Tag.where(title: category_argument).map do |tag|
      tag.relation_type.camelcase.constantize.find_by(id: tag.relation_id).try(:title)
    end.flatten
    obj = TagsCollection.new(tags: tags)
    return [url, obj]
  end

  def categorize_and_perform_request(options={})
    category_name = options[:category_name]
    category_argument = options[:category_argument]
    return nil unless [:category_name, :category_argument].all?
    case category_name
    when "linkedin"
      if Cache.company(category_argument)
        url, obj = "cached", linkedin_query(category_argument)
      else
        url, obj = linkedin_query(category_argument)
      end
    when "tag_details"
      url, obj = tag_details(category_argument)
    when "drag_and_drop"
      url, obj = drag_and_drop(category_argument)
    else
      return nil, nil
    end
    return [url, obj]
  end

end
