module SearchMixin

    require 'uri'

    # result-specific methods

    def load_result_geometry result
        if has_geometry result
            return result[:geometry]
        elsif result[:address].is_a?(String) && result[:address].length > 0
            loc = GeocodeCache.load result[:address]
            if loc != nil
                return { :lat => loc['lat'], :lng => loc['lng'], :cached => true }
            end
        end
        return { :lat  => nil, :lng => nil }
    end

    def load_result_distance result
        if result[:distance].to_i > 0
            return result[:distance]
        elsif has_geometry result
            return Location.calculate_distance(
            @location.latitude.to_f,
            @location.longitude.to_f,
            result[:geometry][:lat],
            result[:geometry][:lng]
            )
        else
            return nil
        end
    end

    def result_pretty_loc result
        if has_geometry result
            return Location.pretty_loc result[:geometry][:lat], result[:geometry][:lng]
        elsif result[:geometry] != nil && result[:geometry][:cached] == true
            return '<i class="fa fa-frown-o"></i>'.html_safe
        else
            return nil
        end
    end

    def result_map result, key
        if has_geometry result
            return GoogleMap.get_result_tn result[:geometry][:lat], result[:geometry][:lng], key
        elsif result[:address] != nil
            return GoogleMap.get_result_tn_by_address result[:address], key
        else
            return nil
        end
    end

    def result_favorite result, favorites
        # FIXME: this is SLOOOOW !!!
        favorites.each do |fav|
            if fav.venue_id.to_s == result[:id].to_s
                if fav.venue_origin.to_s == result[:origin].to_s
                    return true
                end
            end
        end
        return false
    end

    def result_normalize_tags result
        tags = []
        result[:tags].each do |tag|
            tags << Mixin.normalize_tag(tag) if tag.is_a? String
        end
        return tags
    end

    def result_confirm_address result
        if nil == result[:address] || result[:address].strip.length <= 1 || result[:address].strip =~ /^\d+$/
            spinner = '<i class="unknown-data fa fa-spinner fa-spin"></i>'.html_safe
            if has_geometry result
                cached = ReverseGeocodeCache.load result[:geometry][:lat], result[:geometry][:lng]
                if cached == nil
                    return spinner
                else
                    if cached.addr == nil
                        return '<i class="fa fa-frown-o"></i>'.html_safe
                    else
                        return cached.addr
                    end
                end
            else
                return spinner
            end
        else
            return result[:address]
        end
    end

    def email_map detail, key
        if has_geometry detail
            return GoogleMap.get_email_map detail[:geometry][:lat], detail[:geometry][:lng], key
        elsif detail[:address] != nil
            return GoogleMap.get_email_map_by_address detail[:address], key
        else
            return nil
        end
    end

    def has_geometry data
        if data[:geometry] != nil && data[:geometry][:lat] != nil &&  data[:geometry][:lng] != nil
            return true
        else
            return false
        end
    end

    def make_friendly_url detail
        ascii_name = URI.encode(detail[:ascii_name].length ? detail[:ascii_name] : Mixin.generate_random_hash(5))
        id = URI.encode(detail[:id])
        origin = detail[:origin].to_str

        if Mixin.is_ascii detail[:id]
            return '/detail/' + ascii_name + '/' + id + '/' + origin
        else
            return '/detail/' + ascii_name + '/' + origin + '?id=' + id
        end
    end

end
