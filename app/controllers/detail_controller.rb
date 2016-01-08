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

    def load_detail origin, id
        return load origin, id
    end

    private

    def load origin, id
        if Search.allowed_engines.include? origin
            loader = "#{origin.capitalize}VenueLoader".constantize.new id
            postprocess loader.load @location
        end
    end

    def postprocess detail

        generic_engine = SearchEngine.new nil, nil
        key = generic_engine.google_api_key

        if detail[:geometry][:lat] != nil && detail[:geometry][:lat] != nil
            detail[:map] = GoogleMap.get_email_map detail[:geometry][:lat], detail[:geometry][:lng], key
            detail[:pretty_loc] = Location.pretty_loc detail[:geometry][:lat], detail[:geometry][:lng]
        elsif detail[:address] != nil
            detail[:map] = GoogleMap.get_email_map_by_address detail[:address], key
        end
        detail
    end

    def index_params
        params.require(:origin)
        params.require(:id)
        params.permit(:origin, :id)
    end

end
