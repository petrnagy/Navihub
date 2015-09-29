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

    def permalink
        row = Permalink.find_by(permalink_id: params['permalink_id'])
        if row
            @data = YAML.load row.yield
            return render 'detail'
        else render 'empty', :status => 404
        end
    end

    def loadDetail origin, id
        return load origin, id
    end

    private

    def load origin, id
        if Search.allowed_engines.include? origin
            loader = "#{origin.capitalize}VenueLoader".constantize.new id
            return loader.load @location
        end
    end

end
