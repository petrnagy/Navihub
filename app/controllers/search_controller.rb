class SearchController < ApplicationController

    include DetailHelper
    require 'location'

    public

    def index
        init_default_template_params
        index_rewrite_html_variables
        render 'index'
    end

    def find
        parameters = find_params
        @tpl_vars = {} # is filled from several methods
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
            data = reverse_geocode_params
            geocoder = Geocoder.new
            data = geocoder.reverse_geocode data['lat'], data['lng']
            respond_to do |format|
                if data == nil || data.addr == nil
                    html = '<i class="fa fa-frown-o"></i>'.html_safe
                else
                    html = data.addr
                end
                msg = { :status => "ok", :message => "Success!", :html => data.addr }
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
            img_path = Rails.root.join('app', 'assets', 'images', 'noimage.png')
            send_file img_path, type: 'image/png', disposition: 'inline'
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

    def find_rewrite_html_variables parameters
        @page_title = "Searching '" + parameters['term']
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
        %w{lat lng}.each do |required|
            params.require required
            params[required] = params[required].to_f
        end
        params.permit(:lat, :lng)
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

end
