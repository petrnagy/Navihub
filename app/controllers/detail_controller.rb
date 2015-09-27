class DetailController < ApplicationController

    def index
        if params.has_key?('origin') && params.has_key?('id')
            @data = load params['origin'], params['id']
            if @data
                if request.xhr?
                    return render json: @data
                else
                    return render 'detail'
                end
            end
        end
        @data = { :origin => params['origin'] || 'unknown', :id => params['id'] || 'unknown' }
        @failsafe = true
        render 'empty', :status => 404
    end

    private

    def load origin, id
        if Search.allowed_engines.include? origin
            loader = "#{origin.capitalize}VenueLoader".constantize.new id
            return loader.load @location
        end
    end

end
