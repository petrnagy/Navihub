class SearchController < ApplicationController

    public

    @results; @tpl_vars

    def index
        init_default_template_params
        render 'index'
    end

    def find
        parameters = find_params
        @tpl_vars = {} # is filled from several methods
        @results = process_search parameters
        init_template_vars parameters
        if @results.length == 0
            tpl = ( request.xhr? ? '_' : '' ) + 'empty'
            render tpl, :layout => ! request.xhr?
        else
            @data = {:results => @results, :search => @search, :data => @tpl_vars}
            render '_list_find', :layout => false if request.xhr?
        end
    #rescue => e
    #    index
    end

    def empty
    end

    protected

    private

    def process_search parameters
        ts_start = Time.now
        parameters['is_xhr'] = request.xhr?
        search = Search.new parameters, @location, @user
        results = search.search
        @tpl_vars[:total_cnt] = search.total_cnt
        @tpl_vars[:total_time] = (Time.now - ts_start).round(2)
        @tpl_vars[:params] = search.params
        @tpl_vars[:results_from_cache] = search.results_from_cache
        results
    end

    def init_template_vars parameters
        @tpl_vars[:input_params] = parameters
    end

    def init_default_template_params
        @tpl_vars = {}
        @tpl_vars[:input_params] = Hash.new
        @tpl_vars[:input_params]['term'] = ''
        @tpl_vars[:input_params]['radius'] = 0
    end

    def find_params
        params['is_xhr'] = nil
        params['limit'] = 21
        params['step'] = 21
        params['engines'] = Search.allowed_engines
        params['append'] = params.has_key?('append') ? params['append'].to_i : 0

        %W{term order offset radius}.each do |key|
            params.require(key)
            raise "'"+key.to_s+"' was not a String" unless params[key].is_a?(String)
        end

        params.permit(:term, :order, :offset, :radius, :limit, :step, :engines, :is_xhr, :append)
    end

end
