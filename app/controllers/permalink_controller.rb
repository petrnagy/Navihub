class PermalinkController < ApplicationController

    class DataNotLoaded < StandardError
    end
    class EmptyUserId < StandardError
    end
    class NotXhrRequest < StandardError
    end

    require 'digest/md5'
    include RecentMixin

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
        Sitemap.add('/permalink/' + key, params[:controller], data[:name])
        return render json: { status: 'OK', id: key }
    end

    def show
        parameters = show_params
        row = Permalink.find_by(permalink_id: parameters['permalink_id'])
        if row
            @data = YAML.load row.yield
            @notice = 'Friendly notice - this is a <b>permalink</b> page! The content is statically saved in our database and may not reflect your current location or any other infromation change. '
            return render 'detail/detail'
        else render 'empty', :status => 404
        end
    end

    def list

    end

    private

    def create_params
        %w{origin id}.each do |required|
            params.require(required)
            params[required] = Mixin.sanitize(params[required])
        end
        params.permit(:origin, :id)
    end

    def show_params
        params.require(:permalink_id)
        params[:permalink_id] = Mixin.sanitize(params[:permalink_id])
        params.permit(:permalink_id)
    end

end
