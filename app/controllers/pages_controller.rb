class PagesController < ApplicationController
	def root
    GenericCache.destroy_all if params[:clear_cache]
    @url, @obj = categorize_and_perform_request(
      category_name: params[:category_name],
      category_argument: params[:category_argument]
    )
    @url ||= params[:url]
    @url && @obj ||= agent.get(@url)
	end
end
