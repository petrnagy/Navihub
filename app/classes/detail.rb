class Detail

    class UnknownEngine < StandardError
    end
    class BadEngineResponse < StandardError
    end

    include SearchMixin

    def initialize origin, id, location, user
        @origin = origin
        @id = id
        @location = location
        @user = user
    end

    def load
        if Search.allowed_engines.include? @origin
            loader = "#{@origin.capitalize}VenueLoader".constantize.new @id
            data = VenueDetailCache.load @origin, @id
            if data == nil
                data = loader.load(@location)
                raise BadEngineResponse, 'debug: ' + [@id, @origin].to_s if data == nil
                VenueDetailCache.save @origin, @id, data
            end
            mapper = "#{@origin.capitalize}Mapper".constantize.new data
            mapped = postprocess mapper.map_detail(@location)
            # FIX: Nokia detail JSON does not contains full ID
            mapped[:id] = @id if 'nokia' == @origin
            mapped
        else
            raise UnknownEngine, 'debug: ' + origin.to_s
        end
    end

    def postprocess detail
        generic_engine = SearchEngine.new nil, nil
        key = generic_engine.google_api_key
        favorites = Favorite.find_by_user_id @user.id

        detail[:geometry] = load_result_geometry detail
        detail[:distance] = load_result_distance detail
        detail[:pretty_loc] = result_pretty_loc detail
        detail[:email_map] = email_map detail, key
        detail[:distance] = detail[:distance].to_i unless detail[:distance] == nil
        detail[:distance_unit] = 'm' unless detail[:distance] != nil
        detail[:address] = result_confirm_address detail
        detail[:tags] = result_normalize_tags detail
        detail[:ascii_name] = Mixin.normalize_unicode detail[:name]
        detail[:url] = make_friendly_url detail
        detail[:favorite] = result_favorite detail, favorites
        detail
    end

end
