class FavoritesController < ApplicationController

    require 'json'
    require 'ostruct'
    require 'hash_2_object'

    class DataNotLoaded < StandardError
    end
    class EmptyUserId < StandardError
    end
    class NotXhrRequest < StandardError
    end

    @data

    def create
        raise NotXhrRequest unless request.xhr?
        raise EmptyUserId, @user.id.to_s unless @user.id.is_a?(Integer)

        parameters = create_params
        if ! Favorite.find_by(user_id: @user.id, venue_origin: parameters['origin'], venue_id: parameters['id'])
            favorite = Favorite.new
            favorite.user_id = @user.id
            favorite.venue_id = parameters['id']
            favorite.venue_origin = parameters['origin']
            # FIXME: DANGEROUS construct ! ! ! ! ! ! ! !
            favorite.yield = YAML.dump(JSON.parse(parameters['yield']))#favorite.yield = parameters['yield']
            favorite.save
        end
        return render json: { status: 'OK', id: nil }
    end

    def delete
        raise NotXhrRequest unless request.xhr?
        raise EmptyUserId, @user.id.to_s unless @user.id.is_a?(Integer)

        parameters = delete_params

        favorite = Favorite.find_by(user_id: @user.id, venue_origin: parameters['origin'], venue_id: parameters['id'])
        if favorite
            favorite.delete
        end
        return render json: { status: 'OK', id: nil }
    end

    def index
        results = load_results
        if results.length > 0
            @data = {:results => results, :search => nil, :data => nil}
            render 'list'
        else
            render 'empty'
        end
    end

    private

    def load_results
        results = []
        Favorite.where(user_id: @user.id).order(created_at: :desc).find_each do |favorite|
            #results << JSON.parse(favorite.yield, object_class: OpenStruct)
            result = YAML.load(favorite.yield)

            l = Logger.new(STDOUT)
            l.debug result['distance'].to_i

            result['mtime'] = Time.now.usec
            if result['geometry']['lat'] != nil && result['geometry']['lat'] != nil
                result['distance'] = Location.calculate_distance(
                @location.latitude.to_f,
                @location.longitude.to_f,
                result['geometry']['lat'],
                result['geometry']['lng']
                # TODO: zajistit, aby bylo vzdy v metrech
                )
                result['distance_unit'] = 'm'
            elsif result['distance'] != nil && result['distance'].to_f > 0.00
                result['distance'] = result['distance'].to_f
                result['distance_unit'] = ( result['distance_unit'] ? result['distance_unit'] : 'm' )
            else
                result['distance'] = -1
                result['distance_unit'] = nil
                result['distance_in_mins'] = -1
                result['car_distance_in_mins'] = -1
            end

            # FIXME: Tohle je nebezpecne
            if /^<i.*>.*<\/i>$/i.match result['address']
                result['address'] = '<i class="unknown-data fa fa-spinner fa-spin"></i>'.html_safe
            end

            result['json'] = JSON.dump(YAML.load(favorite.yield))
            result['favorite'] = true
            results << result
        end
        results
    end

    def create_params
        params.require(:origin)
        params.require(:id)
        params.require(:yield)
        params.permit(:id, :origin, :yield)
    end

    def delete_params
        params.require(:origin)
        params.require(:id)
        params.permit(:id, :origin)
    end

end
