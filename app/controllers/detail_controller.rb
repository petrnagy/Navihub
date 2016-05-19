class DetailController < ApplicationController

    include RecentMixin

    def index
        parameters = index_params
        @data = load_detail parameters[:origin], parameters[:id]
        rewrite_html_variables
        extend_sitemap
        if @data
            if request.xhr?
                return render json: @data
            else
                return render 'detail'
            end
        end
        @data = { :origin => parameters['origin'] || 'unknown', :id => parameters['id'] || 'unknown' }
        render 'empty', :status => 404
    end

    def load_detail origin, id
        detail = Detail.new origin, id, @location, @user
        return detail.load
    end

    def redirect
        parameters = redirect_params
        data = load_detail parameters[:origin], parameters[:id]
        unless not data or nil == data
            if data[:detail][:website_url]
                return redirect_to data[:detail][:website_url], status: 302
            elsif data[:detail][:url]
                return redirect_to data[:detail][:url], status: 302
            end
        end
        render :template => "errors/404", :status => 404
    end

    private

    def rewrite_html_variables
        @page_title = @data[:name]
    end

    def index_params
        %w{origin id}.each do |required|
            params.require(required)
            params[required] = Mixin.sanitize(params[required])
        end
        params.permit(:origin, :id)
    end

    def redirect_params
        %w{origin id}.each do |required|
            params.require(required)
            params[required] = Mixin.sanitize(params[required])
        end
        params.permit(:origin, :id)
    end

    def extend_sitemap
        url = request.path
        if request.fullpath =~ /\?id=.+/
            url = request.fullpath
        end
        Sitemap.add(url, params[:controller], @data[:name])
    end

end
