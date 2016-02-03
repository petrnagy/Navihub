class DistanceMatrix

    require 'net/http'
    require 'net/https'
    require 'uri'

    def initialize origins, destinations, key
        Rails.logger.debug origins
        @origins = origins
        @destinations = destinations
        @key = key
        @results = nil
    end

    def load
        if @origins.length > 1
            cached = nil
        else
            cached = DistanceMatrixCache.load @origins.first, @destinations.first
        end
        if cached == nil
            preprocess
            url = build_url
            result = parse get url
        else
            result = cached
        end
        unless @origins.length > 1
            DistanceMatrixCache.save @origins.first, @destinations.first, result
        end
        result
    end

    private

    def parse response
      if response.instance_of?(Net::HTTPOK)
        res = JSON.parse response.body
        if 'OK' == res['status']
            return res['rows']
        else
            return nil
        end
      else
        return nil
      end
    end

    def get url
      https = HttpsRequest.new url
      https.get
    end

    def preprocess
        origins = []
        destinations = []
        @origins.each do |origin|
            origin = origin.gsub /(\ |\|)/, ''
            origin = URI.encode origin
            origins << origin
        end
        @destinations.each do |destination|
            destination = destination.gsub /(\ |\|)/, ''
            destination = URI.encode destination
            destinations << destination
        end
        @origins = origins
        @destinations = destinations
    end

    def build_url
        o = ''
        o += 'https://maps.googleapis.com/maps/api/distancematrix/json'
        o += '?key=' + @key
        o += '&origins=' + @origins.join('|')
        o += '&destinations=' + @destinations.join('|')
        o += '&mode=driving'
        o += '&language=en'
        o += '&units=metric'
        URI.encode o
    end

end
