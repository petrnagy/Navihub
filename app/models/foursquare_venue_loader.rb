class FoursquareVenueLoader < GenericVenueLoader
  
  def load location
    data = parse get prepare
    if data
      mapper = FoursquareMapper.new data
      return mapper.map_detail location
    end
  end
  
  private
  
  def prepare
    url = 'https://api.foursquare.com/v2/venues/'
    url += @id.to_s + '/'
    url += '?v=20140806'
    url += '&client_id=' + @foursquare_client_id
    url += '&client_secret=' + @foursquare_client_secret
    URI::escape(url)
  end
  
end