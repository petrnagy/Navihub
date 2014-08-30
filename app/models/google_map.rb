class GoogleMap
 
  def self.get_result_tn lat, lng, key
    o = 'http://maps.googleapis.com/maps/api/staticmap'
    o += '?center=' + lat.to_s + ',' + lng.to_s
    o += '&zoom=15'
    o += '&size=340x100'
    o += '&sensor=false'
    o += '&key=' + key
    o
  end
  
end
