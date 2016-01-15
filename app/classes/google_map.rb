class GoogleMap

  require 'net/http'
  require 'net/https'
  require 'uri'

  def self.get_result_tn lat, lng, key
    self.get_map lat.to_s + ',' + lng.to_s, '340x100', key
  end

  def self.get_result_tn_by_address addr, key
    self.get_map addr, '340x100', key
  end

  def self.get_email_map lat, lng, key
    self.get_map lat.to_s + ',' + lng.to_s, '566x250', key
  end

  def self.get_email_map_by_address addr, key
    self.get_map addr, '566x250', key
  end

  def self.load_static_image url
    uri = URI URI.encode url.to_str
    http = Net::HTTP.new uri.host, uri.port
    response = http.get(uri.request_uri)
    warn = response.header['X-Staticmap-API-Warning']
    return response.body if warn == nil
    if warn.index 'Error geocoding'
      return nil
    else
      return response.body
    end
  end

  private

  def self.get_map center, dimensions, key
    o = 'http://maps.googleapis.com/maps/api/staticmap'
    o += '?center=' + URI.escape(center)
    o += '&zoom=15'
    o += '&size='+dimensions+'&scale=2'
    o += '&sensor=false'
    o += '&key=' + key
    o += '&markers=scale:2|color:green|' + URI.escape(center)
    o
  end

end
