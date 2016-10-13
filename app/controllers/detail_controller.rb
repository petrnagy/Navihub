class DetailController < ApplicationController

    include RecentMixin
    include ApplicationHelper

    def index
        return lazy if is_bot
        return render 'lazy' if not request.xhr?

        parameters = index_params
        @data = load_detail parameters[:origin], parameters[:id]

        return render json: @data
    end

    def lazy
        parameters = index_params
        @data = load_detail parameters[:origin], parameters[:id]
        extend_sitemap if not is_bot
        rewrite_html_variables if is_bot
        return render('detail', :layout => is_bot) if @data

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
                return redirect_to data[:detail][:website_url], status: :found
            elsif data[:detail][:url]
                return redirect_to data[:detail][:url], status: :found
            end
        end
        render :template => "errors/404", :status => 404
    end

    private

    def rewrite_html_variables
        @page_title = @data[:name]
        @page_desc = @data[:name] + ' ' + @data[:address]
        @page_keywords = @page_desc
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
        url.gsub! '/lazy-detail/', '/detail/'
        Sitemap.add(url, params[:controller], @data[:name])
    end

end
