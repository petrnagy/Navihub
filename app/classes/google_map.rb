class GoogleMap

    require 'net/http'
    require 'net/https'
    require 'uri'
    require 'cgi'

    def self.get_result_tn lat, lng, key
        self.get_map lat.to_s + ',' + lng.to_s, '340x100', key, false
    end

    def self.get_result_tn_by_address addr, key
        self.get_map addr, '340x100', key, true
    end

    def self.get_email_map lat, lng, key
        self.get_map lat.to_s + ',' + lng.to_s, '566x250', key, false
    end

    def self.get_email_map_by_address addr, key
        self.get_map addr, '566x250', key, true
    end

    def self.load_static_image url
        cached = GoogleStaticMapCache.load url
        return nil if cached != nil && cached.found == false

        uri = URI URI.encode url.to_str
        http = Net::HTTP.new uri.host, uri.port
        response = http.get(uri.request_uri)
        warn = response.header['X-Staticmap-API-Warning']

        if warn == nil
            GoogleStaticMapCache.save url, true, nil
            return response.body
        elsif warn.index 'Error geocoding'
            GoogleStaticMapCache.save url, false, warn
            return nil
        else
            GoogleStaticMapCache.save url, null, warn
            return nil
        end
    end

    private

    def self.get_map center, dimensions, key, escape
        center = ( escape ? CGI::escape(center) : center ).to_s
        o = 'http://maps.googleapis.com/maps/api/staticmap'
        o += '?center=' + center
        o += '&zoom=15'
        o += '&size='+dimensions+'&scale=2'
        o += '&sensor=false'
        o += '&key=' + key
        o += '&markers=scale:2|color:green|' + center
        o
    end

end
