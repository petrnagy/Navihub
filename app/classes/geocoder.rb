class Geocoder

  require 'net/http'
  require 'net/https'
  require 'uri'

  def initialize
    @key = Rails.configuration.google_api_key
  end

  def geocode addr
    cached = GeocodeCache.load addr
    return cached unless cached == nil

    url = 'https://maps.googleapis.com/maps/api/geocode/json?key=' + @key + '&address=' + addr.to_s
    loc = map parse get(url)
    GeocodeCache.save addr, loc['lat'], loc['lng']
    loc
  end

  def reverse_geocode lat, lng
    cached = ReverseGeocodeCache.load lat, lng
    return cached unless cached == nil

    url = 'https://maps.googleapis.com/maps/api/geocode/json?key=' + @key + '&latlng=' + lat.to_s + ',' + lng.to_s
    addr = map_reverse parse get(url)
    ReverseGeocodeCache.save lat, lng, addr
    addr
  end

  private

  def map data
    {
      'lat' => data['results'].first['geometry']['location']['lat'],
      'lng' => data['results'].first['geometry']['location']['lng']
    }
  end

  def map_reverse data
    data['results'].first['formatted_address']
  end

  def get url
    https = HttpsRequest.new(URI::escape(url))
    https.get
  end

  def parse response
    if response.instance_of?(Net::HTTPOK)
      JSON.parse response.body
    else
      nil
    end
  end

end
