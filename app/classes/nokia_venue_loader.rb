class NokiaVenueLoader < GenericVenueLoader

  def load location
    parse get prepare
  end

  def debug
    prepare
  end

  private

  def prepare
    url = 'https://places.cit.api.here.com/places/v1/places/'
    url += @id.to_s
    url += '?show_refs=pvid'
    url += '&app_id=' + @nokia_app_id
    url += '&app_code=' + @nokia_app_code
    URI::escape(url)
  end

end
