class Detail

    class UnknownEngine < StandardError
    end

    include SearchMixin

    def initialize origin, id, location
        @origin = origin
        @id = id
        @location = location
    end

    def load
        cached = VenueDetailCache.load @origin, @id
        return cached unless cached == nil

        if Search.allowed_engines.include? @origin
            loader = "#{@origin.capitalize}VenueLoader".constantize.new @id
            processed = postprocess loader.load(@location)
            VenueDetailCache.save @origin, @id, processed
            processed
        else
            raise UnknownEngine, 'debug: ' + origin.to_s
        end
    end

    def postprocess detail
        generic_engine = SearchEngine.new nil, nil
        key = generic_engine.google_api_key

        detail[:geometry] = load_result_geometry detail
        detail[:distance] = load_result_distance detail
        detail[:pretty_loc] = result_pretty_loc detail
        detail[:email_map] = email_map detail, key
        detail[:distance] = detail[:distance].to_i unless detail[:distance] == nil
        detail[:distance_unit] = 'm' unless detail[:distance] == nil
        detail[:address] = result_confirm_address detail
        detail[:tags] = result_normalize_tags detail
        detail[:ascii_name] = Mixin.normalize_unicode detail[:name]
        detail[:url] = make_friendly_url detail

        detail
    end

end
