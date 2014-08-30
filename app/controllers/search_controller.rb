class SearchController < ApplicationController

  public
  
  @results; @tpl_vars
  
  def index
  end

  def find
    if params.has_key?('term') && params['term'].is_a?(String) && params['term'].length > 0
      @tpl_vars = {} # is filled from several methods
      @results = process_search params
      init_template_vars params
      if @results.length == 0
        render 'empty'
      else
        @data = {:results => @results, :search => @search, :data => @tpl_vars}
        render '_list_find', :layout => false if request.xhr?
      end
    else
      render 'index'
    end
  end

  def empty
  end
  
  protected
  
  private
  
  def process_search params
    ts_start = Time.now
    location = Location.where(user_id: @user.id, active: true).order('id DESC').first!
    params['is_xhr'] = request.xhr?
    search = Search.new params, location
    results = search.search
    @tpl_vars[:total_cnt] = search.total_cnt
    @tpl_vars[:total_time] = (Time.now - ts_start).round(2)
    @tpl_vars[:params] = search.params
    results
    #@debug = results
  end
  
  def init_template_vars params
    @tpl_vars[:input_params] = params
  end
  
end
