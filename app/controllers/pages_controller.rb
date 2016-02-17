class PagesController < ApplicationController
	def root
    if params[:clear_cache]
      [GenericCache, Tag].each(&:destroy_all)
    end
    @url, @obj = categorize_and_perform_request(
      category_name: params[:category_name],
      category_argument: params[:category_argument]
    )
    @url ||= params[:url]
    @url && @obj ||= agent.get(@url)
	end
  def flashcards
  end
end
