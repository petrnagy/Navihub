class DetailController < ApplicationController

    def index
        parameters = index_params
        @data = load_detail parameters[:origin], parameters[:id]
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
        detail = Detail.new origin, id, @location
        return detail.load
    end

    private

    def index_params
        %w{origin id}.each do |required|
            params.require(required)
            params[required] = Mixin.sanitize(params[required])
        end
        params.permit(:origin, :id)
    end

end
