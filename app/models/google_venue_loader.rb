class GoogleVenueLoader < GenericVenueLoader
  
  def load location
    data = parse get prepare
    if data
      mapper = GoogleMapper.new data
      return mapper.map_detail location
    end
  end
  
  private
  
  def prepare
    url = 'https://maps.googleapis.com/maps/api/place/details/json'
    url += '?placeid=' + @id.to_s
    url += '&key=' + @google_api_key
    URI::escape(url)
  end
  
end