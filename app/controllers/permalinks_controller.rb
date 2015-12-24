class PermalinksController < ApplicationController

    class DataNotLoaded < StandardError
    end
    class EmptyUserId < StandardError
    end
    class NotXhrRequest < StandardError
    end

    require 'digest/md5'

    def create
        raise NotXhrRequest unless request.xhr?
        parameters = create_params

        # injecting variables, can be dangerous !
        detail = DetailController.new
        detail.instance_variable_set(:@user, @user)
        detail.instance_variable_set(:@location, @location)

        data = detail.load_detail parameters['origin'], parameters['id']

        raise DataNotLoaded, data.to_s unless data.is_a?(Hash)
        raise EmptyUserId, @user.id.to_s unless @user.id.is_a?(Integer)

        data_yield = YAML::dump data
        key = Digest::MD5.hexdigest(data_yield)

        if ! Permalink.find_by(permalink_id: key)
            permalink = Permalink.new
            permalink.yield = data_yield
            permalink.permalink_id = key
            permalink.venue_origin = parameters['origin']
            permalink.venue_id = parameters['id']
            permalink.user_id = @user.id
            permalink.save
        end

        return render json: { status: 'OK', id: key }
    end

    def show
        parameters = show_params
        row = Permalink.find_by(permalink_id: parameters['permalink_id'])
        if row
            @data = YAML.load row.yield
             return render 'detail/detail'
        else render 'empty', :status => 404
        end
    end

    private

    def create_params
        params.require(:origin)
        params.require(:id)
        params.permit(:origin, :id)
    end

    def show_params
        params.require(:permalink_id)
        params.permit(:permalink_id)
    end

end
