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
    #location = Location.new @user
    location = nil
    search = Search.new params, location
    search.search
    search.results
    
  end
  
end
