class GoogleMap

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
