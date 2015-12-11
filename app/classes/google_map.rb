class GoogleMap

  def self.get_result_tn lat, lng, key
    o = 'http://maps.googleapis.com/maps/api/staticmap'
    o += '?center=' + lat.to_s + ',' + lng.to_s
    o += '&zoom=15'
    o += '&size=340x100&scale=2'
    o += '&sensor=false'
    o += '&key=' + key
    o += '&markers=size:small|color:green|' + lat.to_s + ',' + lng.to_s
    o
  end

  def self.get_result_tn_by_address addr, key
    o = 'http://maps.googleapis.com/maps/api/staticmap'
    o += '?center=' + URI.escape(addr)
    o += '&zoom=15'
    o += '&size=340x100&scale=2'
    o += '&sensor=false'
    o += '&key=' + key
    o += '&markers=size:small|color:green|' + URI.escape(addr)
    o
  end

end
