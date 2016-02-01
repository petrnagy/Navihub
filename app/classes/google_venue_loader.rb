class GoogleVenueLoader < GenericVenueLoader

  def load location
    parse get prepare
  end

  private

  def prepare
    url = 'https://maps.googleapis.com/maps/api/place/details/json'
    url += '?placeid=' + @id.to_s
    url += '&key=' + @google_api_key
    URI::escape(url)
  end

end
