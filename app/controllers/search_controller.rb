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

    def geocode
        if request.xhr?
            data = geocode_params
            geocoder = Geocoder.new
            data = geocoder.geocode data['addr']
            respond_to do |format|
                msg = { :status => "ok", :message => "Success!", :data => data,
                        :html => Location.pretty_loc( data['lat'], data['lng'] ) }
                format.json { render :json => msg }
            end
        end
    end

    def reverse_geocode
        if request.xhr?
            data = reverse_geocode_params
            geocoder = Geocoder.new
            data = geocoder.reverse_geocode data['lat'], data['lng']
            respond_to do |format|
                msg = { :status => "ok", :message => "Success!", :html => data }
                format.json { render :json => msg }
            end
        end
    end

    def ipinfo
        if request.xhr?
            data = ipinfo_params
            ipinfo = Ipinfo.new
            data = ipinfo.dig data['ip']
            respond_to do |format|
                msg = { :status => "ok", :message => "Success!", :data => data }
                format.json { render :json => msg }
            end
        end
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
        params['order'] = params.has_key?('order') ? params['order'] : 'distance-asc'
        params['offset'] = params.has_key?('offset') ? params['offset'] : '0'
        params['radius'] = params.has_key?('radius') ? params['radius'] : '0'

        %W{term order offset radius}.each do |key|
            params.require(key)
            raise "'"+key.to_s+"' was not a String" unless params[key].is_a?(String)
        end

        params.permit(:term, :order, :offset, :radius, :limit, :step, :engines, :is_xhr, :append)
    end

    def geocode_params
        params.require 'addr'
        params.permit(:addr)
    end

    def reverse_geocode_params
        params.require 'lat'
        params.require 'lng'
        params.permit(:lat, :lng)
    end

    def ipinfo_params
        params.require 'ip'
        params.permit(:ip)
    end


end
