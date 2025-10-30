class SearchController < ApplicationController
  before_action :require_login

  def index
    @query = params[:q].to_s.strip

    if @query.present?
      search_service = SearchService.new(@query, current_person)
      @results = search_service.search
    else
      @results = { channels: [], dms: [], messages: [] }
    end

    respond_to do |format|
      format.json do
        render json: {
          query: @query,
          results: @results,
          total: total_results(@results)
        }
      end
      format.html do
        render partial: "search/results", locals: { results: @results, query: @query }
      end
    end
  end

  private

  def total_results(results)
    results[:channels].size + results[:dms].size + results[:messages].size
  end
end
