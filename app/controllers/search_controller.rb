class SearchController < ApplicationController

    include DetailHelper
    require 'location'
    require 'json'

    public

    def index
        init_default_template_params
        index_rewrite_html_variables
        render 'index'
    end

    def find
        parameters = find_params
        @tpl_vars = {} # is filled from several methods
        @request_params = generate_request_params_json parameters, @request_location
        @results = process_search parameters
        init_template_vars parameters
        find_rewrite_html_variables parameters
        if @results.length == 0
            tpl = ( request.xhr? ? '_' : '' ) + 'empty'
            render tpl, :layout => ! request.xhr?
        else
            @data = {:results => @results, :search => @search, :data => @tpl_vars}
            render '_list_find', :layout => false if request.xhr?
        end
    end

    def empty
    end

    def geocode
        if request.xhr?
            parameters = geocode_params
            geocoder = Geocoder.new
            data = geocoder.geocode parameters['addr']
            respond_to do |format|
                if data == nil || data['lat'] == nil || data['lng'] == nil
                    html = '<i class="fa fa-frown-o"></i>'.html_safe
                else
                    if %w{detail permalink}.include? parameters['source']
                        html = DetailHelper.detail_pretty_loc(
                            Location.pretty_loc(data['lat'], data['lng']),
                            { :lat => data['lat'], :lng => data['lng'] }
                        )
                    else
                        html = Location.pretty_loc( data['lat'], data['lng'] )
                    end
                end
                msg = { :status => "ok", :message => "Success!", :data => data, :html => html }
                format.json { render :json => msg }
            end
        end
    end

    def reverse_geocode
        if request.xhr?
            parameters = reverse_geocode_params
            geocoder = Geocoder.new
            data = geocoder.reverse_geocode parameters['lat'], parameters['lng']
            respond_to do |format|
                if data == nil || data.addr == nil
                    html = '<i class="fa fa-frown-o"></i>'.html_safe
                else
                    if %w{detail permalink}.include? parameters['source']
                        html = DetailHelper.detail_pretty_address parameters['name'], data.addr
                    else
                        html = data.addr
                    end
                end
                msg = { :status => "ok", :message => "Success!", :html => html }
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

    def get_static_map_image
        parameters = validate_static_image_params
        image = GoogleMap.load_static_image parameters['src']
        unless image == nil
            send_data image, type: 'image/png', disposition: 'inline'
        else
            img_path = Rails.root.join('app', 'assets', 'images', 'system', 'noimage.png')
            send_file img_path, type: 'image/png', disposition: 'inline'
        end
    end

    def distance_matrix
        if request.xhr?
            parameters = distance_matrix_params
            matrix = DistanceMatrix.new parameters['origins'], parameters['destinations'], Rails.application.secrets.google_api_key
            results = matrix.load
            respond_to do |format|
                if results != nil
                    result = results[0]['elements'][0]
                    data = {
                        :distance => DetailHelper.detail_pretty_distance(result['distance']['value'].to_i, 'm'),
                        :foot_distance => DetailHelper.detail_pretty_distance_foot(result['distance']['value'].to_i),
                        :car_distance => DetailHelper.detail_pretty_distance_car_precomputed(result['duration']['value'].to_i / 60)
                    }
                    msg = { :status => "ok", :message => "Success!", :data => data }
                    format.json { render :json => msg }
                else
                    format.json { render :json => nil, :status => 500 }
                end
            end
        end
    end

    protected

    private

    def process_search parameters
        ts_start = Time.now
        parameters['is_xhr'] = request.xhr?
        search = Search.new parameters, create_search_location, @user
        results = search.search
        @tpl_vars[:total_cnt] = search.total_cnt
        @tpl_vars[:total_time] = (Time.now - ts_start).round(2)
        @tpl_vars[:params] = search.params
        @tpl_vars[:results_from_cache] = search.results_from_cache
        unless 0 == results.length then
            names = ''
            results.each do |result|
                names = names + ', ' unless names.length == 0
                names = names + result[:name]
            end
            @page_desc = "Search results for '" + parameters['term'] + "': " + names
            @page_keywords = names
        end

        results
    end

    def init_template_vars parameters
        @tpl_vars[:input_params] = parameters
    end

    def find_rewrite_html_variables parameters
        @page_title = "Search results for '" + parameters['term'] + "'"
    end

    def index_rewrite_html_variables

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
        params['term'] = Mixin.sanitize(params['term']).strip

        params.permit(:term, :order, :offset, :radius, :limit, :step, :engines, :is_xhr, :append)
    end

    def geocode_params
        %w{addr source}.each do |required|
            params.require required
            params[required] = Mixin.sanitize(params[required])
        end
        params.permit(:addr, :source)
    end

    def reverse_geocode_params
        %w{lat lng source}.each do |required|
            params.require required
            params[required] = params[required].to_f unless 'source' === required
        end
        params['name'] = Mixin.sanitize params['name'] if params.has_key? 'name'
        params.permit(:lat, :lng, :source, :name)
    end

    def ipinfo_params
        params.require 'ip'
        params[:ip] = Mixin.sanitize(params[:ip])
        params.permit(:ip)
    end

    def validate_static_image_params
        params.require 'src'
        params[:src] = Mixin.sanitize(params[:src])
        params.permit(:src)
    end

    def distance_matrix_params
        %w{origins destinations}.each do |required|
            params.require required
            raise 'Param' + required + ' was not an array' unless params[required].is_a? Array
        end
        unless params['origins'].length === params['destinations'].length
            raise 'There was not the same count of origins as destinations'
        end
        params.permit(:origins => [], :destinations => [])
    end

    def create_search_location
        if params.has_key?('lat') and params.has_key?('lng')
            lat = params[:lat].to_f
            lng = params[:lng].to_f
            if Location.possible lat, lng
                return Location.new(
                user_id:        @user.id,
                latitude:       lat,
                longitude:      lng,
                lock:           false,
                active:         true
                )
            end
        end
        @location
    end

    def generate_request_params_json parameters, location
        JSON.dump({
            :term   => parameters['term'],
            :sort   => parameters['order'],
            :radius => parameters['radius'].to_i,
            :offset => parameters['offset'].to_i + parameters['step'].to_i,
            :loc    => {
                :lat => location.latitude.to_f,
                :lng => location.longitude.to_f
            }
        })
    end

end
