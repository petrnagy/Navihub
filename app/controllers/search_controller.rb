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
    location = Location.where(user_id: @user.id, active: true).order('id DESC').first!
    search = Search.new params, location
    results = search.search
    @debug = results
  end
  
end
