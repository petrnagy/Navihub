class DetailController < ApplicationController

    def index
        parameters = index_params
        @data = load parameters['origin'], parameters['id']
        if @data
            if request.xhr?
                return render json: @data
            else
                return render 'detail'
            end
        end
        @data = { :origin => parameters['origin'] || 'unknown', :id => parameters['id'] || 'unknown' }
        @failsafe = true
        render 'empty', :status => 404
    end

    def permalink
        parameters = permalink_params
        row = Permalink.find_by(permalink_id: parameters['permalink_id'])
        if row
            @data = YAML.load row.yield
            return render 'detail'
        else render 'empty', :status => 404
        end
    end

    def load_detail origin, id
        return load origin, id
    end

    private

    def load origin, id
        if Search.allowed_engines.include? origin
            loader = "#{origin.capitalize}VenueLoader".constantize.new id
            return loader.load @location
        end
    end

    def index_params
        params.require(:origin)
        params.require(:id)
        params.permit(:origin, :id)
    end
    def permalink_params
        params.require(:permalink_id)
        params.permit(:permalink_id)
    end

end
