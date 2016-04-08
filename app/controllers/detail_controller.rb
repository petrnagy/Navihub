class DetailController < ApplicationController

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

    def extend_sitemap
        url = request.path
        if request.fullpath =~ /\?id=.+/
            url = request.fullpath
        end
        Sitemap.add(url, params[:controller], @data[:name])
    end

end
