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
        if ! Favorite.find_by_params @user.id, parameters['origin'], parameters['id']
            Favorite.create_with_yield(
            @user.id,
            parameters['origin'],
            parameters['id'],
            # FIXME: DANGEROUS construct !
            YAML.dump(JSON.parse(parameters['yield']))
            )
        end
        return render json: { status: 'OK', id: nil }
    end

    def delete
        raise NotXhrRequest unless request.xhr?
        raise EmptyUserId, @user.id.to_s unless @user.id.is_a?(Integer)

        parameters = delete_params

        favorite = Favorite.find_by_params @user.id, parameters['origin'], parameters['id']
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
        favorites = Favorite.load_by_user_id @user.id
        return results if favorites.length == 0
        favorites.each do |favorite|
            #results << JSON.parse(favorite.yield, object_class: OpenStruct)
            result = YAML.load(favorite.yield)

            l = Logger.new(STDOUT)
            l.debug result['distance'].to_i

            result['mtime'] = Time.now.usec
            if result['geometry']['lat'] != nil && result['geometry']['lng'] != nil
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
        %w{origin id yield}.each do |required|
            params.require required
            params[required] = Mixin.sanitize(params[required]) unless required == 'yield' # yield je JSON
        end
        params.permit(:id, :origin, :yield)
    end

    def delete_params
        %w{origin id}.each do |required|
            params.require required
            params[required] = Mixin.sanitize(params[required])
        end
        params.permit(:id, :origin)
    end

end
