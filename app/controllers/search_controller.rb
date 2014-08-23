class SearchController < ApplicationController

  public
  
  @results = []
  
  def index
  end

  def find term = nil, order = nil, offset = nil
    if term.class.name.downcase == 'string' && term.length
      @results = process_search term, order, offset
      if @results.length
        render 'find'
      else
        render 'empty'
      end
      
    else  
      render 'find'
    end
  end

  def empty
  end
  
  protected
  
  private
  
  def process_search term, order, offset
    # todo
    # 1) require model
    # 2) process search in cache
    # 3) process searchvia api
    [1,2,3]
  end
  
end
