class SearchController < ApplicationController

  public
  
  @results
  
  def index
  end

  def find
    if params.has_key?('term') && params['term'].is_a?(String) && params['term'].length > 0
      @results = process_search params
      render 'empty' if @results.length == 0
    else
      render 'index'
    end
  end

  def empty
  end
  
  protected
  
  private
  
  def process_search params
    search = Search.new params
    search.search
    search.get_results
    @debug = search.get_results
  end
  
end
